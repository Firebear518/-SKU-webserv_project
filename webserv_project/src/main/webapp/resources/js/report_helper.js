document.addEventListener("DOMContentLoaded", function() {
    // 1. 제외할 페이지 경로 (로그인, 회원가입 등)
    var currentUrl = window.location.href;
    var excludePages = ['login', 'join', 'register', 'sign']; 

    for (var i = 0; i < excludePages.length; i++) {
        if (currentUrl.indexOf(excludePages[i]) !== -1) return;
    }

    // 2. 버튼 생성 및 스타일 설정
    var btn = document.createElement('button');
    btn.id = 'floatingReportBtn';
    btn.innerHTML = '🚨 신고';
    
    btn.style.position = 'fixed';
    btn.style.bottom = '30px';
    btn.style.right = '30px';
    btn.style.zIndex = '9999';
    btn.style.padding = '10px 15px';
    btn.style.backgroundColor = '#dc3545';
    btn.style.color = 'white';
    btn.style.border = 'none';
    btn.style.borderRadius = '50px';
    btn.style.cursor = 'pointer';
    btn.style.boxShadow = '0 4px 6px rgba(0,0,0,0.3)';

    // 3. 클릭 이벤트 (구버전 호환 문법 적용)
    btn.onclick = function() {
        var pIdEl = document.querySelector('input[name="productId"]');
        var sIdEl = document.querySelector('input[name="sellerId"]');
        
        var pId = (pIdEl) ? pIdEl.value : 'none';
        var sId = (sIdEl) ? sIdEl.value : 'none';
        
        window.open('/webserv_project/views/report/report_form.jsp?productId=' + pId + '&reportedUserId=' + sId, 
                    'ReportWindow', 'width=450,height=550');
    };

    // 4. body에 추가
    document.body.appendChild(btn);
});