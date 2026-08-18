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
public class UserHasLifestyleId implements Serializable {
    private static final long serialVersionUID = 1666072158564239784L;
    @Column(name = "user_userId", nullable = false)
    private String userId;

    @Column(name = "lifestyle_lifestyleId", nullable = false)
    private Integer lifestyleLifestyleid;

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || Hibernate.getClass(this) != Hibernate.getClass(o)) return false;
        UserHasLifestyleId entity = (UserHasLifestyleId) o;
        return Objects.equals(this.lifestyleLifestyleid, entity.lifestyleLifestyleid) &&
                Objects.equals(this.userId, entity.userId);
    }

    @Override
    public int hashCode() {
        return Objects.hash(lifestyleLifestyleid, userId);
    }

}