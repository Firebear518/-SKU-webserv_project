<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>올댓카드 - AI 상품 등록</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    
    <style>
        /* 메인 업로드 박스 */
        .main-upload-zone {
            perspective: 1000px;
            cursor: pointer;
            display: flex;
            justify-content: center;
            margin-bottom: 25px;
        }
        .tilt-card {
            width: 240px;
            height: 336px;
            border-radius: 14px;
            box-shadow: 0 12px 30px rgba(0,0,0,0.15);
            overflow: hidden;
            background-color: #f8f9fa;
            border: 2px dashed #ffc107;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            transform-style: preserve-3d;
            transition: border-color 0.2s;
        }
        .tilt-card:hover {
            border-color: #e0a800;
            background-color: #f1f3f5;
        }
        /* 메인 카드 이미지 비율 유지 */
        .tilt-card img {
            width: 100%;
            height: 100%;
            object-fit: cover; 
            object-position: center;
            border-radius: 12px;
        }
        
        /* 상세 사진 업로드 박스 */
        .detail-upload-box {
            width: 85px;
            height: 85px;
            border: 2px dashed #dee2e6;
            border-radius: 8px;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            color: #adb5bd;
            transition: all 0.2s;
        }
        .detail-upload-box:hover {
            background-color: #f8f9fa;
            border-color: #0d6efd;
            color: #0d6efd;
        }

        /* 상세 사진 프리뷰 아이템 래퍼 */
        .preview-item-wrapper {
            position: relative;
            width: 85px;
            height: 85px;
            border: 1px solid #dee2e6;
            border-radius: 8px;
            overflow: hidden;
            background-color: #fff;
            cursor: zoom-in;
        }
        /* 상세 증명 사진 비율 채우기 */
        .preview-item-wrapper img {
            width: 100%;
            height: 100%;
            object-fit: cover; 
            object-position: center; 
        }
        /* 개별 이미지 삭제 X 버튼 */
        .btn-delete-img {
            position: absolute;
            top: 2px;
            right: 2px;
            width: 18px;
            height: 18px;
            background-color: rgba(0, 0, 0, 0.6);
            color: #fff;
            border-radius: 50%;
            font-size: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            border: none;
            z-index: 10; 
            transition: background-color 0.2s;
        }
        .btn-delete-img:hover {
            background-color: rgba(220, 53, 69, 0.9);
        }
    </style>
</head>
<body class="bg-light">

    <jsp:include page="/views/common/header.jsp" />

    <div class="container my-5">
        <div class="row justify-content-center">
            <div class="col-lg-8">
                <div class="card shadow-sm border-0 rounded-3">
                    <div class="card-body p-4 p-md-5">
                        <h3 class="fw-bold text-dark mb-4"><i class="bi bi-plus-circle text-warning"></i> 경매 상품 등록</h3>
                        
                        <form action="${pageContext.request.contextPath}/product/register" method="post" enctype="multipart/form-data" onsubmit="return submitWithFinalImages(event, this)">
                            
                            <div class="text-center mb-4">
                                <label class="form-label fw-bold d-block text-start mb-2">1. 메인 대표 카드 사진 (3D 홀로그램 미리보기 전용)</label>
                                <div class="main-upload-zone" onclick="document.getElementById('mainImageInput').click()">
                                    <div class="tilt-card" data-tilt>
                                        <div id="uploadGuideText" class="p-3 text-center text-muted">
                                            <i class="bi bi-plus-circle-fill text-warning fs-1 mb-2 d-block"></i>
                                            <span class="small fw-bold">클릭하여 메인 카드 등록</span>
                                        </div>
                                        <img id="previewMainImg" class="d-none" alt="메인 대표 카드">
                                    </div>
                                </div>
                                <input type="file" id="mainImageInput" name="mainImage" class="d-none" accept="image/*" onchange="previewMainCard(this)" required>
                            </div>

                            <div class="mb-4">
                                <label class="form-label fw-bold">2. 상태 증명 상세 사진 (최대 5장)</label>
                                <div class="d-flex gap-2 flex-wrap align-items-center">
                                    <div class="detail-upload-box" onclick="document.getElementById('detailInput').click()">
                                        <i class="bi bi-camera-fill fs-4"></i>
                                        <span class="small" id="imgCountText">0 / 5</span>
                                    </div>
                                    <input type="file" id="detailInput" multiple class="d-none" accept="image/*" onchange="appendDetailImages(this)">
                                    
                                    <div id="detailPreviewContainer" class="d-flex gap-2 flex-wrap"></div>
                                </div>
                                <div class="form-text mt-2">모서리 흠집, 테두리 마모 등 카드의 세부 상태를 확인할 수 있는 사진을 올려주세요. (상세 사진을 클릭하면 크게 볼 수 있습니다)</div>
                            </div>

                            <hr class="my-4 opacity-25">

                            <div class="mb-3">
                                <label for="productName" class="form-label fw-bold">카드 명칭</label>
                                <div class="input-group">
                                    <input type="text" class="form-control" id="productName" name="productName" placeholder="예: 리자몽 VMAX SSR" required>
                                    <button type="button" id="aiBtn" class="btn btn-info text-white fw-bold" onclick="generateAIDescription()">
                                        <span id="aiBtnText"><i class="bi bi-robot"></i> AI 설명 추천</span>
                                        <span id="aiSpinner" class="spinner-border spinner-border-sm d-none" role="status"></span>
                                    </button>
                                </div>
                            </div>

                            <div class="mb-3">
                                <label for="category" class="form-label fw-bold">카테고리</label>
                                <select class="form-select" id="category" name="category" required>
                                    <option value="" selected disabled>카테고리 선택</option>
                                    <option value="POKEMON">포켓몬 카드</option>
                                    <option value="YUGIOH">유희왕 카드</option>
                                    <option value="SPORTS">스포츠 카드</option>
                                    <option value="ETC">기타 수집 카드</option>
                                </select>
                            </div>

                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label for="startPrice" class="form-label fw-bold">경매 시작가</label>
                                    <div class="input-group">
                                        <span class="input-group-text">₩</span>
                                        <input type="number" class="form-control" id="startPrice" name="startPrice" placeholder="0" required>
                                    </div>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label for="endTime" class="form-label fw-bold">경매 마감 기한</label>
                                    <select class="form-select" id="endTime" name="endTime" required>
                                        <option value="3">3일 후 마감</option>
                                        <option value="5">5일 후 마감</option>
                                        <option value="7" selected>7일 후 마감</option>
                                    </select>
                                </div>
                            </div>

                            <div class="mb-4">
                                <label for="description" class="form-label fw-bold">상품 설명</label>
                                <textarea class="form-control" id="description" name="description" rows="8" placeholder="AI 버튼을 누르거나 상세 내용을 수동 기입하세요." required></textarea>
                            </div>

                            <input type="file" id="finalDetailImagesInput" name="detailImages" multiple class="d-none">

                            <button type="submit" class="btn btn-warning w-100 py-3 fw-bold fs-5 shadow-sm">
                                <i class="bi bi-check-circle-fill"></i> 경매 게시하기
                            </button>
                            
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="modal fade" id="imageZoomModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered modal-md">
            <div class="modal-content bg-transparent border-0 text-center">
                <div class="modal-body p-0 position-relative">
                    <button type="button" class="btn-close btn-close-white position-absolute top-0 end-0 m-3 fs-4" data-bs-dismiss="modal" aria-label="Close" style="z-index: 1055;"></button>
                    <img id="modalZoomImg" src="" class="img-fluid rounded shadow-lg" style="max-width: 100%; max-height: 85vh; object-fit: contain;" alt="확대 이미지">
                </div>
            </div>
        </div>
    </div>

    <jsp:include page="/views/common/footer.jsp" />

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/vanilla-tilt/1.8.1/vanilla-tilt.min.js"></script>

    <script>
        const MAX_FILE_SIZE = 10 * 1024 * 1024; // 파일 제한 크기: 10MB

        // 1. Vanilla-Tilt 메인 카드 3D 모션 연동
        VanillaTilt.init(document.querySelectorAll(".tilt-card"), {
            max: 22,
            speed: 500,
            glare: true,
            "max-glare": 0.5,
            scale: 1.03
        });

        // 2. 메인 대표 카드 업로드 프리뷰
        function previewMainCard(input) {
            if (input.files && input.files[0]) {
                const file = input.files[0];
                
                if (!file.type.startsWith('image/')) {
                    alert('⚠️ 이미지 파일만 업로드 가능합니다.');
                    input.value = "";
                    return;
                }
                if (file.size > MAX_FILE_SIZE) {
                    alert('⚠️ 메인 이미지 크기는 10MB를 초과할 수 없습니다.');
                    input.value = "";
                    return;
                }

                const reader = new FileReader();
                reader.onload = function(e) {
                    const img = document.getElementById('previewMainImg');
                    const guide = document.getElementById('uploadGuideText');
                    
                    img.src = e.target.result; 
                    img.classList.remove('d-none');
                    guide.classList.add('d-none');
                }
                reader.readAsDataURL(file);
            }
        }

        // 3. 다중 이미지 누적 보관 큐
        let selectedFilesQueue = [];

        function appendDetailImages(input) {
            const files = input.files;
            
            if (selectedFilesQueue.length + files.length > 5) {
                alert("⚠️ 상세 사진은 최대 5장까지만 등록 가능합니다. \n현재 등록 가능 여유: " + (5 - selectedFilesQueue.length) + "장");
                input.value = ""; 
                return;
            }

            for (let i = 0; i < files.length; i++) {
                if (!files[i].type.startsWith('image/')) {
                    alert('⚠️ 이미지 파일만 업로드 가능합니다.');
                    input.value = "";
                    return;
                }
                if (files[i].size > MAX_FILE_SIZE) {
                    alert('⚠️ 사진 한 장당 10MB를 초과할 수 없습니다.');
                    input.value = "";
                    return;
                }
                selectedFilesQueue.push(files[i]);
            }

            input.value = "";
            renderDetailPreviews();
        }

        // 4. 상세 사진 프리뷰 출력 (★JSP EL 문법 충돌 우려로 인해 백틱 기호 완전히 전면 폐기★)
        function renderDetailPreviews() {
            const container = document.getElementById('detailPreviewContainer');
            const countText = document.getElementById('imgCountText');
            
            container.innerHTML = ""; 
            countText.innerText = selectedFilesQueue.length + " / 5"; 

            if (selectedFilesQueue.length === 0) return;

            const readPromises = selectedFilesQueue.map((file) => {
                return new Promise((resolve) => {
                    const reader = new FileReader();
                    reader.onload = function(e) {
                        resolve(e.target.result); 
                    };
                    reader.readAsDataURL(file);
                });
            });

            Promise.all(readPromises).then((imgUrls) => {
                imgUrls.forEach((url, index) => {
                    const wrapper = document.createElement('div');
                    wrapper.className = "preview-item-wrapper";
                    
                    // 💡 해결책: 백틱 대신 문자열 더하기(+)를 사용하여 JSP가 코드를 갈취하지 못하게 격리함
                    let htmlContent = "";
                    htmlContent += '<img src="' + url + '" alt="상세사진" onclick="openZoomModal(this.src)">';
                    htmlContent += '<button type="button" class="btn-delete-img" onclick="removeSelectedFile(event, ' + index + ')">';
                    htmlContent += '<i class="bi bi-x"></i>';
                    htmlContent += '</button>';
                    
                    wrapper.innerHTML = htmlContent;
                    container.appendChild(wrapper);
                });
            });
        }

        // 5. 상세 이미지 크게 보기 모달 오픈 함수
        function openZoomModal(imgSrc) {
            document.getElementById('modalZoomImg').src = imgSrc;
            const zoomModal = new bootstrap.Modal(document.getElementById('imageZoomModal'));
            zoomModal.show();
        }

        // 6. 상세 이미지 개별 취소
        function removeSelectedFile(event, index) {
            event.stopPropagation(); 
            selectedFilesQueue.splice(index, 1); 
            renderDetailPreviews(); 
        }

        // 7. 최종 전송 파일 맵핑 주입
        function submitWithFinalImages(event, formElement) {
            const dataTransfer = new DataTransfer();
            selectedFilesQueue.forEach(file => {
                dataTransfer.items.add(file);
            });
            document.getElementById('finalDetailImagesInput').files = dataTransfer.files;
            return true;
        }

        // 8. AI 설명 추천 비동기 통신
        function generateAIDescription() {
            const pName = document.getElementById("productName").value;
            const aiBtn = document.getElementById("aiBtn");
            const aiBtnText = document.getElementById("aiBtnText");
            const aiSpinner = document.getElementById("aiSpinner");

            if (!pName || pName.trim() === "") {
                alert("⚠️ 상품명을 입력해야 AI 추천 설명을 받을 수 있습니다.");
                document.getElementById("productName").focus();
                return;
            }

            aiBtn.disabled = true;
            aiBtnText.classList.add("d-none");
            aiSpinner.classList.remove("d-none");

            // 여기 있는 ${pageContext.request.contextPath}는 진짜 JSP 백엔드 변수가 맞으므로 그대로 유지합니다.
            fetch("${pageContext.request.contextPath}/api/ai-recommend", {
                method: "POST",
                headers: { "Content-Type": "application/x-www-form-urlencoded" },
                body: "productName=" + encodeURIComponent(pName)
            })
            .then(res => {
                if (!res.ok) {
                    throw new Error("서버 에러 발생");
                }
                return res.text();
            })
            .then(data => {
                document.getElementById("description").value = data;
            })
            .catch(err => {
                alert("⚠️ AI 추천 설명을 가져오는 중 오류가 발생했습니다.");
                console.error(err);
            })
            .finally(() => {
                aiBtn.disabled = false;
                aiBtnText.classList.remove("d-none");
                aiSpinner.classList.add("d-none");
            });
        }
    </script>
</body>
</html>