package dev.masterhesse.diglearn.user;

import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/users")
public class AdminUserController {

    private final UserService userService;

    @PostMapping("/{userId}/promote-teacher")
    @PreAuthorize("hasRole('ADMIN')")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void promoteTeacher(@PathVariable String userId) {
        userService.promoteStudentToTeacher(userId);
    }
}