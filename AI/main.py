# 표준 라이브러리
import json
import math
import os
import time
from collections import defaultdict, deque
from queue import Queue
from threading import Thread

# 서드파티 라이브러리
import cv2
import numpy as np
import pandas as pd
import pika
import socketio
import torch
from fastapi import FastAPI
from haversine import haversine
from pydantic import BaseModel
from ultralytics import YOLO

# 로컬 애플리케이션/라이브러리 모듈
from tracker import *

app = FastAPI()
sio = socketio.Client()

# 메시지 데이터 모델
class Message(BaseModel):
    cctv_name: str
    speed: int

# GPU 설정
os.environ["CUDA_DEVICE_ORDER"] = "PCI_BUS_ID"
os.environ["CUDA_VISIBLE_DEVICES"] = "9"

torch.backends.cudnn.enabled = True
torch.backends.cudnn.benchmark = True

print("CUDA 사용 가능 여부:", torch.cuda.is_available())
device = torch.device("cuda")
print(f"Using device: {device}")

# YOLO 모델 로드 및 장치에 할당
model = YOLO("yolov9c.pt").to(device)

# 좌표 설정 및 행렬 계산
src = np.float32([[56.0, 317.0], [609.0, 337.0], [250.0, 54.0], [454.0, 58.0]])  # 영상 이미지 내 픽셀 좌표(좌하, 우하, 좌상, 우상)
dst = np.float32([[35.080958, 128.907801], [35.080953, 128.907683], [35.080665, 128.907803], [35.080665, 128.907685]])  # 픽셀 좌표의 실제 위도, 경도(좌하, 우하, 좌상, 우상)
dst = np.float32([haversine(dst[0], i, unit="m") for i in dst])
dst = np.float32([[dst[0], dst[0]], [dst[1], dst[0]], [dst[0], dst[2]], [dst[1], dst[2]]])
M = cv2.getPerspectiveTransform(src, dst)

# 차량 속도 및 위치 정보 저장
car_dict = defaultdict(deque)
area_dict = defaultdict(deque)
speed_dict = defaultdict(list)

# RabbitMQ 설정 함수
def connect_to_rabbitmq():
    credentials = pika.PlainCredentials("guest", "guest")
    parameters = pika.ConnectionParameters(host="", port=, credentials=credentials)
    connection = pika.BlockingConnection(parameters)
    channel = connection.channel()
    channel.queue_declare(queue="hello", durable=True)
    return connection, channel

rabbitmq_connection, channel = connect_to_rabbitmq()

print(f"RabbitMQ 연결 상태: {'열려 있음' if rabbitmq_connection.is_open else '닫혀 있음'}")
print(f"RabbitMQ 채널 상태: {'열려 있음' if channel.is_open else '닫혀 있음'}")

# 이미지 바이트 변환 함수
def bytesToImage(image_bytes):
    image_array = np.frombuffer(image_bytes, dtype=np.uint8)
    image_data = cv2.imdecode(image_array, cv2.IMREAD_COLOR)
    return image_data

# 이미지 전송 함수
def ImageToBytesAndSend(image_data):
    _, buffer = cv2.imencode(".jpg", image_data)
    image_bytes = buffer.tobytes()
    sio.emit("sendCCTVImage2", {"CCTVImage": image_bytes})

# 속도 데이터 전송 함수
def sendSpeedData(speed):
    sio.emit("sendSpeedData", {"time": time.time(), "speed": speed})
    

# 객체 클래스 리스트
class_list = ["person", "bicycle", "car", "motorcycle", "airplane", "bus", "train", "truck", "boat", "traffic light", "fire hydrant", "stop sign", "parking meter", "bench", "bird", "cat", "dog", "horse", "sheep", "cow", "elephant", "bear", "zebra", "giraffe", "backpack", "umbrella", "handbag", "tie", "suitcase", "frisbee", "skis", "snowboard", "sports ball", "kite", "baseball bat", "baseball glove", "skateboard", "surfboard", "tennis racket", "bottle", "wine glass", "cup", "fork", "knife", "spoon", "bowl", "banana", "apple", "sandwich", "orange", "broccoli", "carrot", "hot dog", "pizza", "donut", "cake", "chair", "couch", "potted plant", "bed", "dining table", "toilet", "tv", "laptop", "mouse", "remote", "keyboard", "cell phone", "microwave", "oven", "toaster", "sink", "refrigerator", "book", "clock", "vase", "scissors", "teddy bear", "hair drier", "toothbrush"]

tracker = Tracker()

frame_count = 0
fps = 24

data_queue = Queue()

# 마지막 메시지 발송 시간을 저장할 전역 변수 추가
last_dispatch_time = time.time()

def process_queue():
    global rabbitmq_connection, channel
    while True:
        data = data_queue.get()
        if data is None:
            break
        handle_image(data)
        data_queue.task_done()

def handle_image(data):
    global rabbitmq_connection, channel, last_dispatch_time
    start_time = time.time()
    frame = bytesToImage(data["CCTVImage"])
    image_trans_time = time.time()
    print(f"이미지 변환: {image_trans_time - start_time}")
    torch.cuda.empty_cache()
    results = model.predict(frame, verbose=False)
    predict_time = time.time()
    print(f"객체 감지: {predict_time - image_trans_time}")
    
    d = results[0].boxes.data
    d = d.detach().cpu().numpy()
    px = pd.DataFrame(d).astype("float")
    
    boxes = []

    for index, row in px.iterrows():
        x1, y1 = int(row[0]), int(row[1])
        x2, y2 = int(row[2]), int(row[3])
        w = abs(x1 - x2)
        h = abs(y1 - y2)
        d = int(row[5])
        c = class_list[d]
        class_id = int(row[5])
        class_name = class_list[class_id]
        if 'car' in c:
            boxes.append([x1,y1,w,h])

    bboxes = tracker.update(boxes)
    # print(f"추적된 객체 수: {len(bboxes)}")

    for bbox in bboxes:
        x1, y1, w, h, track_id = bbox
        x2 = x1 + w
        y2 = y1 + h
        cx = int(x1 + (w / 2))
        cy = int(y1 + (h / 2))
        current_area = w * h
        src_coor = np.float32([[cx], [cy], [1]])
        lat_long_coor = np.dot(M, src_coor)
        lat_long_coor = np.array([lat_long_coor[i][0] / lat_long_coor[2][0] for i in range(3)])

        np.set_printoptions(precision=12)

        if not car_dict[track_id]:
            car_dict[track_id].append(lat_long_coor)
            area_dict[track_id].append(y1)
        else:
            car_dict[track_id].append(lat_long_coor)
            area_dict[track_id].append(y1)
            if area_dict[track_id][-2] < y1:
                difference = car_dict[track_id][-2] - lat_long_coor
                distance = math.sqrt(difference[0] ** 2 + difference[1] ** 2)
                temp_speed = distance * fps / 1000 * 3600
                speed_dict[track_id].append(temp_speed)

                if len(speed_dict[track_id]) >= 4:
                    speed = sum(speed_dict[track_id][-4:]) // 4
                    print(f"ID: {track_id} & 속도: {speed}km/h")
                    if y1 > 150 and speed > 20:
                        # print("메시지 발송")
                        # sendSpeedData(speed)
                        current_time = time.time()
                        if current_time - last_dispatch_time >= 3:
                            last_dispatch_time = current_time
                            print("메시지 발송")
                            sendSpeedData(speed)
                            message = {"cctv_name": "cctv-1", "speed": speed + 30}
                            message_json = json.dumps(message)
                            try:
                                channel.basic_publish(exchange="", routing_key="hello", body=message_json)
                            except (pika.exceptions.AMQPConnectionError, pika.exceptions.ChannelClosedByBroker, pika.exceptions.StreamLostError):
                                print("RabbitMQ 연결 끊김, 재연결 시도 중...")
                                rabbitmq_connection, channel = connect_to_rabbitmq()
                                channel.basic_publish(exchange="", routing_key="hello", body=message_json)

                    # 차량 이미지에 박스와 속도 표시
                    cv2.circle(frame, (cx, cy), 4, (0, 0, 255), -1)
                    cv2.rectangle(frame, (x1, y1), (x2, y2), (0, 255, 0), 2)
                    cv2.putText(frame, f"ID: {track_id} Speed: {speed} km/h", (x1, y1 - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 0), 2)

            if len(car_dict[track_id]) > 30:
                car_dict[track_id].popleft()
                area_dict[track_id].popleft()

    speed_time = time.time()
    print(f"속도 측정: {speed_time - predict_time}")
    ImageToBytesAndSend(frame)
    end_time = time.time()
    print(f"전체 시간: {end_time - start_time}")
    print("-----------------------------------------")

@sio.event
def getCCTVImage(data):
    global frame_count
    frame_count += 1
    # print(frame_count)
    data_queue.put(data)

@app.on_event("startup")
def start_connection():
    sio.connect("")
    Thread(target=process_queue, daemon=True).start()

@app.on_event("shutdown")
def shutdown_connection():
    sio.disconnect()
    data_queue.put(None)  # Queue 처리 스레드를 종료시키기 위해 None을 보냄
