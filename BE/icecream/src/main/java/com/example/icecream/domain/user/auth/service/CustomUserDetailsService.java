package com.example.icecream.domain.user.auth.service;

import com.example.icecream.domain.user.auth.error.AuthErrorCode;
import com.example.icecream.common.exception.NotFoundException;
import com.example.icecream.domain.user.entity.User;
import com.example.icecream.domain.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.Collection;
import java.util.Collections;

@Service
@RequiredArgsConstructor
public class CustomUserDetailsService implements UserDetailsService {

    private final UserRepository userRepository;

    @Override
    public UserDetails loadUserByUsername(String loginId) throws UsernameNotFoundException {
        return userRepository.findByLoginIdAndIsDeletedFalse(loginId)
                .map(this::createUserDetails)
                .orElseThrow(() -> new NotFoundException(AuthErrorCode.USER_NOT_FOUND.getMessage()));
    }

    private UserDetails createUserDetails(User user) {
        return org.springframework.security.core.userdetails.User.builder()
                .username(user.getLoginId())
                .password(user.getPassword())
                .authorities(getAuthorities(user))
                .build();
    }

    private Collection<? extends GrantedAuthority> getAuthorities(User user) {
        String role = user.getIsParent() ? "ROLE_PARENT" : "ROLE_CHILD";
        return Collections.singletonList(new SimpleGrantedAuthority(role));
    }
}
