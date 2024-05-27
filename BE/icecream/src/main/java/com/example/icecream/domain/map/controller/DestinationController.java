package com.example.icecream.domain.map.controller;

import com.example.icecream.common.dto.ApiResponseDto;
import com.example.icecream.domain.map.dto.DestinationModifyDto;
import com.example.icecream.domain.map.dto.DestinationRegisterDto;
import com.example.icecream.domain.map.dto.DestinationResponseDto;
import com.example.icecream.domain.map.service.DestinationService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/destination")
public class DestinationController {

    private final DestinationService destinationService;

    @GetMapping
    public ResponseEntity<ApiResponseDto<List<DestinationResponseDto>>> getDestinations(@AuthenticationPrincipal UserDetails userDetails,
                                                                                        @RequestParam("user_id") Integer childId) {
        List<DestinationResponseDto> destinations = destinationService.getDestinations(Integer.parseInt(userDetails.getUsername()), childId);
        return ApiResponseDto.success("목적지 조회에 성공하였습니다.", destinations);
    }

    @PostMapping
    public ResponseEntity<ApiResponseDto<String>> registerDestination(@AuthenticationPrincipal UserDetails userDetails,
                                                                      @RequestBody @Valid DestinationRegisterDto destinationRegisterDto) {
        destinationService.registerDestination(Integer.parseInt(userDetails.getUsername()), destinationRegisterDto);
        return ApiResponseDto.created("목적지 등록에 성공하였습니다.");
    }

    @PatchMapping
    public ResponseEntity<ApiResponseDto<String>> modifyDestination(@AuthenticationPrincipal UserDetails userDetails,
                                                                    @RequestBody @Valid DestinationModifyDto destinationModifyDto) {
        destinationService.modifyDestination(Integer.parseInt(userDetails.getUsername()), destinationModifyDto);
        return ApiResponseDto.success("목적지 수정에 성공하였습니다.");
    }

    @DeleteMapping
    public ResponseEntity<ApiResponseDto<String>> deleteDestination(@AuthenticationPrincipal UserDetails userDetails,
                                                                    @RequestParam("destination_id") Integer destinationId) {
        destinationService.deleteDestination(Integer.parseInt(userDetails.getUsername()), destinationId);
        return ApiResponseDto.success("목적지 삭제에 성공하였습니다.");
    }
}
