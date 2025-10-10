package sit.chat2date.cp25ssi2.entities;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.Hibernate;

import java.io.Serializable;
import java.util.Objects;

@Getter
@Setter
@Embeddable
public class UserHasTravelstyleId implements Serializable {
    private static final long serialVersionUID = -3263685253042598860L;
    @Column(name = "user_userId", nullable = false)
    private Integer userUserid;

    @Column(name = "travelstyle_travelId", nullable = false)
    private Integer travelstyleTravelid;

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || Hibernate.getClass(this) != Hibernate.getClass(o)) return false;
        UserHasTravelstyleId entity = (UserHasTravelstyleId) o;
        return Objects.equals(this.userUserid, entity.userUserid) &&
                Objects.equals(this.travelstyleTravelid, entity.travelstyleTravelid);
    }

    @Override
    public int hashCode() {
        return Objects.hash(userUserid, travelstyleTravelid);
    }

}