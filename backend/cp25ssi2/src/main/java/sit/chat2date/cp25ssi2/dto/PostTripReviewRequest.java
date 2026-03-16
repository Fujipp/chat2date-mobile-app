package sit.chat2date.cp25ssi2.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PostTripReviewRequest {
    private String partnerId;

    @JsonProperty("is_satisfied")
    private Boolean isSatisfied;

    @JsonProperty("want_to_continue")
    private Boolean wantToContinue;

    @JsonProperty("want_to_unmatch")
    private Boolean wantToUnmatch;
}