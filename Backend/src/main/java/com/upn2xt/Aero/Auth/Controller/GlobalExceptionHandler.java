package com.upn2xt.Aero.Auth.Controller;

import com.upn2xt.Aero.Auth.Dtos.ErrorResponse;
import io.swagger.annotations.Api;
import org.springframework.dao.DataAccessException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.sql.SQLException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.stream.Collectors;

/**
 * Global exception handler for handling SQL and database-related errors across
 * all controllers.
 * Returns standardized error responses with HTTP 500 status for database
 * errors.
 */
@RestControllerAdvice
@Api(tags = "Error Handling", description = "Global error handling for database and SQL exceptions")
public class GlobalExceptionHandler {

    /**
     * Handles validation exceptions thrown when @Valid annotation fails.
     *
     * @param ex The MethodArgumentNotValidException that was thrown
     * @return ResponseEntity containing validation error details with HTTP 400
     *         status
     */
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ErrorResponse> handleValidationException(MethodArgumentNotValidException ex) {
        String errorMessages = ex.getBindingResult().getFieldErrors().stream()
                .map(error -> error.getField() + ": " + error.getDefaultMessage())
                .collect(Collectors.joining(", "));

        ErrorResponse errorResponse = new ErrorResponse(
                HttpStatus.BAD_REQUEST.value(),
                "Validation Error",
                errorMessages,
                LocalDateTime.now().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME));
        return new ResponseEntity<>(errorResponse, HttpStatus.BAD_REQUEST);
    }

    /**
     * Handles SQL exceptions thrown by database operations.
     *
     * @param ex The SQLException that was thrown
     * @return ResponseEntity containing error details with HTTP 500 status
     */
    @ExceptionHandler(SQLException.class)
    public ResponseEntity<ErrorResponse> handleSQLException(SQLException ex) {
        ErrorResponse errorResponse = new ErrorResponse(
                HttpStatus.INTERNAL_SERVER_ERROR.value(),
                "Database Error",
                "SQL Error: " + ex.getMessage(),
                LocalDateTime.now().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME));
        return new ResponseEntity<>(errorResponse, HttpStatus.INTERNAL_SERVER_ERROR);
    }

    /**
     * Handles Spring's DataAccessException which wraps various database errors.
     *
     * @param ex The DataAccessException that was thrown
     * @return ResponseEntity containing error details with HTTP 500 status
     */
    @ExceptionHandler(DataAccessException.class)
    public ResponseEntity<ErrorResponse> handleDataAccessException(DataAccessException ex) {
        ErrorResponse errorResponse = new ErrorResponse(
                HttpStatus.INTERNAL_SERVER_ERROR.value(),
                "Database Error",
                "Database Access Error: " + ex.getMostSpecificCause().getMessage(),
                LocalDateTime.now().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME));
        return new ResponseEntity<>(errorResponse, HttpStatus.INTERNAL_SERVER_ERROR);
    }
}
