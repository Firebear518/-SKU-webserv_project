<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>로그인 페이지</title>
</head>
<body>
    <h2>회원가입을 축하합니다!</h2>
    <p>이제 아래에서 로그인을 시도해 보세요.</p>
    
    <form action="LoginServlet" method="post">
        아이디: <input type="text" name="user_id"><br>
        비밀번호: <input type="password" name="password"><br>
        <button type="submit">로그인</button>
    </form>
</body>
</html> 