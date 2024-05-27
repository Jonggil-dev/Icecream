import math

class Tracker:
    def __init__(self):
        # 각 객체의 중심 위치를 저장하는 딕셔너리를 초기화
        # 객체의 ID를 키로 하고 중심 좌표를 값
        self.center_points = {}
        # 객체에 고유 ID를 할당하기 위한 카운터를 초기화
        # 새 객체가 감지될 때마다 이 값이 증가
        self.id_count = 0

    # 감지된 객체들의 리스트를 인자로 받고, 이 객체들을 추적하거나 새로운 ID를 할당
    def update(self, objects_rect):
        # 감지된 객체들의 바운딩 박스와 ID를 저장할 리스트
        objects_bbs_ids = []

        # 객체들의 중심점 계산
        for rect in objects_rect:
            x, y, w, h = rect
            cx = (x + x + w) // 2
            cy = (y + y + h) // 2

            # 현재 객체가 이전 프레임에서 이미 감지된 객체인지를 판단하기 위한 플래그를 False로 설정
            same_object_detected = False

            # 저장된 중심점들을 반복하면서 각 객체의 ID와 중심 좌표를 검사
            for id, pt in self.center_points.items():
                # 현재 객체의 중심과 기존 객체 중심 사이의 유클리드 거리를 계산
                dist = math.hypot(cx - pt[0], cy - pt[1])

                # 계산된 거리가 35픽셀 미만이면 같은 객체로 간주
                if dist < 35:
                    # 중심점을 갱신
                    self.center_points[id] = (cx, cy)
                    # 바운딩 박스와 ID 정보를 리스트에 추가
                    objects_bbs_ids.append([x, y, w, h, id])
                    # 같은 객체가 감지되었음을 표시
                    same_object_detected = True
                    break

            # 새로운 객체가 감지되었을 경우 ID 할당
            if same_object_detected is False:
                # 새 ID와 중심점을 딕셔너리에 추가
                self.center_points[self.id_count] = (cx, cy)
                # 바운딩 박스와 새 ID를 리스트에 추가
                objects_bbs_ids.append([x, y, w, h, self.id_count])
                # ID 카운터를 1 증가
                self.id_count += 1

        # 사용 중이지 않은 ID를 정리하기 위해 새로운 중심점 딕셔너리 초기화
        new_center_points = {}

        # 갱신된 바운딩 박스와 ID 리스트를 반복
        for obj_bb_id in objects_bbs_ids:
            # 리스트에서 객체 ID를 추출
            _, _, _, _, object_id = obj_bb_id
            # 해당 ID의 중심점을 가져오기
            center = self.center_points[object_id]
            # 새 중심점 딕셔너리에 ID와 중심점을 저장
            new_center_points[object_id] = center

        # 중심점 딕셔너리를 새 딕셔너리로 갱신
        self.center_points = new_center_points.copy()

        # 갱신된 바운딩 박스와 ID 리스트를 반환
        return objects_bbs_ids