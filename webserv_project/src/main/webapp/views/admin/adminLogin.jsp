<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>올댓카드 - 관리자 로그인</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-dark">
<div class="container my-5">
    <div class="row justify-content-center">
        <div class="col-md-4">
            <div class="card border-0 shadow">
                <div class="card-body p-5">
                    <h4 class="fw-bold text-center mb-4">🔒 관리자 로그인</h4>

                    <% if ("invalid".equals(request.getParameter("error"))) { %>
                    <div class="alert alert-danger small py-2 text-center">아이디 또는 비밀번호가 틀렸습니다.</div>
                    <% } %>

                    <form action="<%= request.getContextPath() %>/admin/login" method="post">
                        <div class="mb-3">
                            <label class="form-label fw-semibold">관리자 아이디</label>
                            <input type="text" class="form-control" name="adminId" required autofocus>
                        </div>
                        <div class="mb-4">
                            <label class="form-label fw-semibold">비밀번호</label>
                            <input type="password" class="form-control" name="adminPw" required>
                        </div>
                        <button type="submit" class="btn btn-danger w-100 fw-bold py-2">로그인</button>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>