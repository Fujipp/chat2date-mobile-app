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
public class UserHasInterestId implements Serializable {
    private static final long serialVersionUID = 5230127598127734923L;
    @Column(name = "user_userId", nullable = false)
    private String userId;

    @Column(name = "interest_interestId", nullable = false)
    private Integer interestInterestid;

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || Hibernate.getClass(this) != Hibernate.getClass(o)) return false;
        UserHasInterestId entity = (UserHasInterestId) o;
        return Objects.equals(this.userId, entity.userId) &&
                Objects.equals(this.interestInterestid, entity.interestInterestid);
    }

    @Override
    public int hashCode() {
        return Objects.hash(userId, interestInterestid);
    }

}