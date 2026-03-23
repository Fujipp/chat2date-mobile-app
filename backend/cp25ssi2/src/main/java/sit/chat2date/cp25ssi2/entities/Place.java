package sit.chat2date.cp25ssi2.entities;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.ColumnDefault;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Getter
@Setter
@Entity
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "places")
public class Place {

    @Id
    @Column(name = "placeId", nullable = false, length = 255)
    private String placeId;

    @Column(name = "placeName", nullable = false, length = 255)
    private String placeName;

    @Column(name = "address", columnDefinition = "TEXT")
    private String address;

    @Column(name = "imageUrl", columnDefinition = "TEXT")
    private String imageUrl;

    @Column(name = "latitude", nullable = false, precision = 11, scale = 8)
    private BigDecimal latitude;

    @Column(name = "longitude", nullable = false, precision = 11, scale = 8)
    private BigDecimal longitude;

    @ColumnDefault("CURRENT_TIMESTAMP")
    @Column(name = "createdAt", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        if (createdAt == null) {
            createdAt = LocalDateTime.now();
        }
    }
}
