package com.example.icecream.domain.goal.entity;

import com.example.icecream.common.entity.BaseEntity;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import lombok.*;

@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor
@Builder
@Getter
@Entity
@Table(name="goal")
public class Goal extends BaseEntity {

        @Id
        @GeneratedValue(strategy = GenerationType.IDENTITY)
        private int id;

        @Column(name = "user_id", nullable = false)
        @NotNull
        private int userId;

        @Column(name = "period", nullable = false)
        @NotNull
        private int period;

        @Column(name = "record", nullable = false)
        @NotNull
        private int record = 0;

        @Column(name = "content", nullable = false, length = 500)
        @NotNull
        private String content;

        @Column(name = "is_active", nullable = false)
        @NotNull
        private Boolean isActive = true;


        public void updateGoal(int period, String content) {
                this.period = period;
                this.content = content;
        }

        public void updateRecord(int record) {
                this.record = record;
        }

        public void deactivateGoal() {
                this.isActive = false;
        }
}
