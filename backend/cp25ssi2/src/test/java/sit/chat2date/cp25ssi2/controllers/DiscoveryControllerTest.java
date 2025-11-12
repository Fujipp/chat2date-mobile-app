//package sit.chat2date.cp25ssi2.controllers;
//
//import com.fasterxml.jackson.databind.ObjectMapper;
//import org.junit.jupiter.api.Test;
//import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
//import org.springframework.context.annotation.Import;
//import org.springframework.http.MediaType;
//import org.springframework.security.test.context.support.WithMockUser;
//import org.springframework.test.web.servlet.MockMvc;
//import sit.chat2date.cp25ssi2.dto.FeedbackRequest;
//import sit.chat2date.cp25ssi2.enums.ActionType;
//import sit.chat2date.cp25ssi2.exceptions.GlobalExceptionHandler;
//import sit.chat2date.cp25ssi2.services.DiscoveryService;
//
//import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
//import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
//import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;
//
///**
// * ใช้ @WebMvcTest โหลดเฉพาะชั้น MVC + Security
// * @Import: ใส่ Service จริง (in-memory) และ GlobalExceptionHandler
// */
//@WebMvcTest(controllers = DiscoveryController.class)
//@Import({DiscoveryService.class, GlobalExceptionHandler.class})
//class DiscoveryControllerTest {
//
//    @Autowired MockMvc mvc;
//    @Autowired ObjectMapper om;
//
//    // -------- GET /api/v1/discovery/ --------
//
//    @Test
//    @WithMockUser(roles = "USER")
//    void getDiscovery_ok() throws Exception {
//        mvc.perform(get("/api/v1/discovery/")
//                .param("minDistance", "0")
//                .param("maxDistance", "10")
//                .param("userId", "u_1")
//                .header("accessToken", "dummy"))
//           .andExpect(status().isOk())
//           .andExpect(jsonPath("$.user.id").exists())
//           .andExpect(jsonPath("$.user.phone").exists());
//    }
//
//    @Test
//    @WithMockUser(roles = "USER")
//    void getDiscovery_badRequest_whenMinGreaterThanMax() throws Exception {
//        mvc.perform(get("/api/v1/discovery/")
//                .param("minDistance", "10")
//                .param("maxDistance", "5")
//                .param("userId", "u_1")
//                .header("accessToken", "dummy"))
//           .andExpect(status().isBadRequest())
//           .andExpect(jsonPath("$.status").value(400));
//    }
//
//    @Test
//    @WithMockUser(roles = "USER")
//    void getDiscovery_notFound_whenUserMissing() throws Exception {
//        mvc.perform(get("/api/v1/discovery/")
//                .param("minDistance", "0")
//                .param("maxDistance", "5")
//                .param("userId", "u_x")
//                .header("accessToken", "dummy"))
//           .andExpect(status().isNotFound())
//           .andExpect(jsonPath("$.status").value(404));
//    }
//
//    @Test
//    void getDiscovery_unauthorized_whenNoAuth() throws Exception {
//        // ไม่มี @WithMockUser -> ไม่มี auth => 401
//        mvc.perform(get("/api/v1/discovery/")
//                .param("minDistance", "0")
//                .param("maxDistance", "5")
//                .param("userId", "u_1")
//                .header("accessToken", "dummy"))
//           .andExpect(status().isUnauthorized());
//    }
//
//    // -------- POST /api/v1/discovery/feedback --------
//
//    @Test
//    @WithMockUser(roles = "USER")
//    void feedback_created_notmatch() throws Exception {
//        FeedbackRequest req = new FeedbackRequest();
//        req.setActorUserId("u_1");
//        req.setTargetUserId("u_2");
//        req.setAction(ActionType.LIKE);
//
//        mvc.perform(post("/api/v1/discovery/feedback")
//                .header("accessToken", "dummy")
//                .contentType(MediaType.APPLICATION_JSON)
//                .content(om.writeValueAsString(req)))
//           .andExpect(status().isCreated())
//           .andExpect(jsonPath("$.response").value("notmatch"));
//    }
//
//    @Test
//    @WithMockUser(roles = "USER")
//    void feedback_created_match() throws Exception {
//        // step1: u_2 like u_1
//        FeedbackRequest r1 = new FeedbackRequest();
//        r1.setActorUserId("u_2");
//        r1.setTargetUserId("u_1");
//        r1.setAction(ActionType.LIKE);
//
//        mvc.perform(post("/api/v1/discovery/feedback")
//                .header("accessToken", "dummy")
//                .contentType(MediaType.APPLICATION_JSON)
//                .content(om.writeValueAsString(r1)))
//           .andExpect(status().isCreated());
//
//        // step2: u_1 like u_2 -> match
//        FeedbackRequest r2 = new FeedbackRequest();
//        r2.setActorUserId("u_1");
//        r2.setTargetUserId("u_2");
//        r2.setAction(ActionType.LIKE);
//
//        mvc.perform(post("/api/v1/discovery/feedback")
//                .header("accessToken", "dummy")
//                .contentType(MediaType.APPLICATION_JSON)
//                .content(om.writeValueAsString(r2)))
//           .andExpect(status().isCreated())
//           .andExpect(jsonPath("$.response").value("match"));
//    }
//
//    @Test
//    void feedback_unauthorized_whenNoAuth() throws Exception {
//        FeedbackRequest req = new FeedbackRequest();
//        req.setActorUserId("u_1");
//        req.setTargetUserId("u_2");
//        req.setAction(ActionType.LIKE);
//
//        mvc.perform(post("/api/v1/discovery/feedback")
//                .header("accessToken", "dummy")
//                .contentType(MediaType.APPLICATION_JSON)
//                .content(om.writeValueAsString(req)))
//           .andExpect(status().isUnauthorized());
//    }
//
//    @Test
//    @WithMockUser(roles = "GUEST") // ไม่มี ROLE_USER -> 403
//    void feedback_forbidden_whenRoleNotAllowed() throws Exception {
//        FeedbackRequest req = new FeedbackRequest();
//        req.setActorUserId("u_1");
//        req.setTargetUserId("u_2");
//        req.setAction(ActionType.LIKE);
//
//        mvc.perform(post("/api/v1/discovery/feedback")
//                .header("accessToken", "dummy")
//                .contentType(MediaType.APPLICATION_JSON)
//                .content(om.writeValueAsString(req)))
//           .andExpect(status().isForbidden());
//    }
//
//    @Test
//    @WithMockUser(roles = "USER")
//    void feedback_badRequest_whenSelfLike() throws Exception {
//        FeedbackRequest req = new FeedbackRequest();
//        req.setActorUserId("u_1");
//        req.setTargetUserId("u_1");
//        req.setAction(ActionType.LIKE);
//
//        mvc.perform(post("/api/v1/discovery/feedback")
//                .header("accessToken", "dummy")
//                .contentType(MediaType.APPLICATION_JSON)
//                .content(om.writeValueAsString(req)))
//           .andExpect(status().isBadRequest())
//           .andExpect(jsonPath("$.status").value(400));
//    }
//}
