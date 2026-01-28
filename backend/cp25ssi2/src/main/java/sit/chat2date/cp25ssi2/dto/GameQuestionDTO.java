package sit.chat2date.cp25ssi2.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyOrder;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@JsonPropertyOrder({ "questionId", "question", "options", "correct" })
public class GameQuestionDTO {
    private String questionId;
    @JsonProperty("question")
    private String text;
    private List<String> options;
    @JsonProperty("correct")
    private String correct;
}
