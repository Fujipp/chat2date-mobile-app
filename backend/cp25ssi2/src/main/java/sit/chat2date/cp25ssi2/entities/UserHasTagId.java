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
public class UserHasTagId implements Serializable {
    private static final long serialVersionUID = -6826211503512329422L;
    @Column(name = "user_userId", nullable = false)
    private Integer userUserid;

    @Column(name = "tag_tagId", nullable = false)
    private Integer tagTagid;

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || Hibernate.getClass(this) != Hibernate.getClass(o)) return false;
        UserHasTagId entity = (UserHasTagId) o;
        return Objects.equals(this.userUserid, entity.userUserid) &&
                Objects.equals(this.tagTagid, entity.tagTagid);
    }

    @Override
    public int hashCode() {
        return Objects.hash(userUserid, tagTagid);
    }

}