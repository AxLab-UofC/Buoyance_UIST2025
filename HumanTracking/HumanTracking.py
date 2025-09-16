import cv2 as cv
from pythonosc import udp_client, dispatcher, osc_server
import mediapipe as mp
import numpy as np
import mediapipe.python.solutions.hands as mp_hands
import mediapipe.python.solutions.drawing_utils as drawing
import mediapipe.python.solutions.drawing_styles as drawing_styles
import threading

# Initialize OSC client and dispatcher
client = udp_client.SimpleUDPClient("127.0.0.1", 3333)
disp = dispatcher.Dispatcher()

# Global variable to track the current mode
current_mode = None
hand_frame = None
body_frame = None
frame_lock = threading.Lock()
quit_flag = threading.Event()

# Hand tracking setup
mp_hands_module = mp_hands.Hands(static_image_mode=False, max_num_hands=2, min_detection_confidence=0.5)

# Body tracking setup
mp_pose = mp.solutions.pose
mp_drawing = mp.solutions.drawing_utils
pose = mp_pose.Pose(static_image_mode=False, model_complexity=1, smooth_landmarks=True, min_detection_confidence=0.5)

# To store the previous frame's landmark positions for hands
previous_hand_landmarks = {'left': None, 'right': None}

# To store previous leg positions for body tracking
previous_legs_movement = {"left_leg": None, "right_leg": None}

# Function to handle hand tracking
def hand_tracking():
    global hand_frame
    cam = cv.VideoCapture(0)

    while cam.isOpened() and current_mode == "hand":
        success, frame = cam.read()
        if not success:
            print("Camera Frame not available")
            continue

        frame_rgb = cv.cvtColor(frame, cv.COLOR_BGR2RGB)
        hands_detected = mp_hands_module.process(frame_rgb)
        frame = cv.cvtColor(frame_rgb, cv.COLOR_RGB2BGR)

        movements = {'left': "none", 'right': "none"}

        if hands_detected.multi_hand_landmarks:
            for hand_landmarks, hand_class in zip(hands_detected.multi_hand_landmarks, hands_detected.multi_handedness):
                hand_label = hand_class.classification[0].label.lower()  # 'left' or 'right'
                drawing.draw_landmarks(frame, hand_landmarks, mp_hands.HAND_CONNECTIONS, drawing_styles.get_default_hand_landmarks_style(), drawing_styles.get_default_hand_connections_style())

                if previous_hand_landmarks[hand_label]:
                    direction = detect_hand_movement(hand_label, hand_landmarks, previous_hand_landmarks[hand_label])
                    movements[hand_label] = direction

                previous_hand_landmarks[hand_label] = hand_landmarks

        message = f"left hand {movements['right']}, right hand {movements['left']}"
        client.send_message("/hand_movement", message)
        #print(message)

        with frame_lock:
            #hand_frame = frame.copy()
            hand_frame = cv.resize(frame, (350, 300))

    cam.release()

# Function to handle body tracking
def body_tracking():
    global body_frame
    cam = cv.VideoCapture(0)

    while cam.isOpened() and current_mode == "body":
        success, frame = cam.read()
        if not success:
            print("Camera Frame not available")
            continue

        frame_rgb = cv.cvtColor(frame, cv.COLOR_BGR2RGB)
        results = pose.process(frame_rgb)

        left_arm_angle = None
        right_arm_angle = None
        legs_moving = {"left_leg": False, "right_leg": False}
        walking_status = "not walking"

        if results.pose_landmarks:
            landmarks = results.pose_landmarks.landmark

            left_shoulder = [landmarks[mp_pose.PoseLandmark.LEFT_SHOULDER.value].x, landmarks[mp_pose.PoseLandmark.LEFT_SHOULDER.value].y]
            left_elbow = [landmarks[mp_pose.PoseLandmark.LEFT_ELBOW.value].x, landmarks[mp_pose.PoseLandmark.LEFT_ELBOW.value].y]
            left_wrist = [landmarks[mp_pose.PoseLandmark.LEFT_WRIST.value].x, landmarks[mp_pose.PoseLandmark.LEFT_WRIST.value].y]
            left_arm_angle = calculate_angle(left_shoulder, left_elbow)

            right_shoulder = [landmarks[mp_pose.PoseLandmark.RIGHT_SHOULDER.value].x, landmarks[mp_pose.PoseLandmark.RIGHT_SHOULDER.value].y]
            right_elbow = [landmarks[mp_pose.PoseLandmark.RIGHT_ELBOW.value].x, landmarks[mp_pose.PoseLandmark.RIGHT_ELBOW.value].y]
            right_wrist = [landmarks[mp_pose.PoseLandmark.RIGHT_WRIST.value].x, landmarks[mp_pose.PoseLandmark.RIGHT_WRIST.value].y]
            right_arm_angle = calculate_angle(right_shoulder, right_elbow)

            left_knee = landmarks[mp_pose.PoseLandmark.LEFT_KNEE.value].y
            left_ankle = landmarks[mp_pose.PoseLandmark.LEFT_ANKLE.value].y
            right_knee = landmarks[mp_pose.PoseLandmark.RIGHT_KNEE.value].y
            right_ankle = landmarks[mp_pose.PoseLandmark.RIGHT_ANKLE.value].y

            if previous_legs_movement["left_leg"] is not None:
                legs_moving["left_leg"] = np.abs(left_knee - previous_legs_movement["left_leg"]["knee"]) > 0.001 or np.abs(left_ankle - previous_legs_movement["left_leg"]["ankle"]) > 0.001
            if previous_legs_movement["right_leg"] is not None:
                legs_moving["right_leg"] = np.abs(right_knee - previous_legs_movement["right_leg"]["knee"]) > 0.001 or np.abs(right_ankle - previous_legs_movement["right_leg"]["ankle"]) > 0.001

            previous_legs_movement["left_leg"] = {"knee": left_knee, "ankle": left_ankle}
            previous_legs_movement["right_leg"] = {"knee": right_knee, "ankle": right_ankle}

            if legs_moving["left_leg"] and legs_moving["right_leg"]:
                walking_status = "walking"

            mp_drawing.draw_landmarks(frame, results.pose_landmarks, mp_pose.POSE_CONNECTIONS)

        client.send_message("/left_arm_angle", left_arm_angle if left_arm_angle is not None else "none")
        client.send_message("/right_arm_angle", right_arm_angle if right_arm_angle is not None else "none")
        client.send_message("/walking_status", walking_status)

        with frame_lock:
            #body_frame = frame.copy()
            body_frame = cv.resize(frame, (350, 300))

    cam.release()

def calculate_angle(a, b):
    """Calculate the angle between three points a and b"""
    a = np.array(a)  # First point
    b = np.array(b)  # Second point (the angle vertex)
    
    radians = np.arctan2(a[1] - b[1], abs(a[0] - b[0]))
    angle = np.degrees(radians)
    if angle > 90:
        angle = angle - 180
    elif angle < -90:
        angle = angle + 180
    
    return angle

def detect_hand_movement(hand_label, current_landmarks, previous_landmarks):
    current_x = sum([lm.x for lm in current_landmarks.landmark]) / len(current_landmarks.landmark)
    current_y = sum([lm.y for lm in current_landmarks.landmark]) / len(current_landmarks.landmark)
    current_z = sum([lm.z for lm in current_landmarks.landmark]) / len(current_landmarks.landmark)
    
    previous_x = sum([lm.x for lm in previous_landmarks.landmark]) / len(previous_landmarks.landmark)
    previous_y = sum([lm.y for lm in previous_landmarks.landmark]) / len(previous_landmarks.landmark)
    previous_z = sum([lm.z for lm in previous_landmarks.landmark]) / len(previous_landmarks.landmark)
    
    dx = current_x - previous_x
    dy = current_y - previous_y
    dz = current_z - previous_z

    if abs(dz) > 0.008:
        direction = "forward" if dz > 0 else "backward"
    elif abs(dx) > abs(dy) and abs(dx) > 0.01:
        direction = "right" if dx < 0 else "left"
    elif abs(dy) > abs(dx) and abs(dy) > 0.01:
        direction = "up" if dy < 0 else "down"
    else:
        direction = "none"

    return f"{direction}"

def osc_handler(address, *args):
    global current_mode
    mode = args[0]
    
    if mode == "hand" and current_mode != "hand":
        current_mode = "hand"
        threading.Thread(target=hand_tracking, daemon=True).start()
    elif mode == "body" and current_mode != "body":
        current_mode = "body"
        threading.Thread(target=body_tracking, daemon=True).start()
    elif mode == "quit":
        current_mode = "quit"
        quit_flag.set()  # Set the flag to indicate quit

# Register OSC handlers
disp.map("/mode", osc_handler)

# Start the OSC server in a thread
server_thread = threading.Thread(target=lambda: osc_server.ThreadingOSCUDPServer(("127.0.0.1", 3334), disp).serve_forever())
server_thread.daemon = True
server_thread.start()

# Main loop for GUI
def main_loop():
    global hand_frame, body_frame

    while True:
        if current_mode == "hand":
            with frame_lock:
                if hand_frame is not None:
                    cv.imshow("Hand Tracking", hand_frame)
        elif current_mode == "body":
            with frame_lock:
                if body_frame is not None:
                    cv.imshow("Body Tracking", body_frame)

        if (cv.waitKey(1) & 0xFF == ord('q')) or (current_mode == "quit"):
            quit_flag.set()
            break

    cv.destroyAllWindows()

# Start the main GUI loop
main_loop()
