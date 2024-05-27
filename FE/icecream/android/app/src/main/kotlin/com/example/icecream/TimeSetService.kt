package com.example.icecream

data class TimeSet(
    val destinationId: Int,
    val name: String,
    val icon: Int,
    val latitude: Double,
    val longitude: Double,
    val startTime: String,
    val endTime: String,
    val day: String
)

class TimeSetService {
    // 예제 데이터를 반환하는 메소드
    fun fetchTimeSets(userId: String): List<TimeSet> {
        // 실제 데이터 가져오기 로직으로 대체 필요
        return listOf(
            TimeSet(-1, "Home", 1, 35.123, 128.123, "08:00", "09:00", "1111100"), // 월~금
            TimeSet(-1, "School", 2, 35.456, 128.456, "01:00", "23:00", "1111100")  // 월~금
        )
    }
}
