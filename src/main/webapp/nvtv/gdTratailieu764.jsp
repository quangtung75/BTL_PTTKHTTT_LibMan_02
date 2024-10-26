<%@ page import="com.google.gson.Gson" %>
<%@ page import="java.util.logging.Logger" %>
<%@ page import="java.util.List" %>
<%@ page import="libman.dao.TaiLieuMuon764DAO" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.util.Date" %>
<%@ page import="libman.model.*" %>
<%@ page import="com.google.gson.GsonBuilder" %><%--
  Created by IntelliJ IDEA.
  User: vongn
  Date: 10/25/2024
  Time: 4:06 PM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Nhận trả tài liệu</title>
    <link rel="stylesheet" type="text/css" href="../style/gdTratailieu764.css">
</head>

<body>
<%
    PhieuTra764 phieuTra = new PhieuTra764();
    phieuTra.setNgaytra(new Date());
    phieuTra.setTongtienphat(0);

    ThanhVien764 nvtv = (ThanhVien764) session.getAttribute("nvtv");
    NhanVienThuVien764 nguoitiepnhan = new NhanVienThuVien764();
    nguoitiepnhan.setId(nvtv.getId());
    nguoitiepnhan.setHoTen(nvtv.getHoTen());
    phieuTra.setNguoitiepnhan(nguoitiepnhan);

    List<TaiLieuMuon764> taiLieuChuaTra = null;
    BanDoc764 nguoitra = null;

    String mathe = request.getParameter("mathe");
    String banDocJsonEncoded = request.getParameter("banDocJson");
    String banDocJson = java.net.URLDecoder.decode(banDocJsonEncoded, "UTF-8");
    //String banDocJson = "{\"diemuytin\":10,\"id\":1,\"taiKhoan\":\"taiKhoan\",\"matKhau\":\"matKhau\",\"hoTen\":\"hoTen\",\"email\":\"email\",\"sdt\":\"sdt\",\"diaChi\":\"diaChi\",\"ghiChu\":\"ghiChu\",\"vaiTro\":\"vaiTro\"}";

    if (banDocJson != null && !banDocJson.isEmpty()) {
        Gson gson = new Gson();
        nguoitra = gson.fromJson(banDocJson, BanDoc764.class);
        phieuTra.setNguoitra(nguoitra);
%>
<div class="info-bar">
    <p><strong>Thông tin người trả:</strong></p>
    <p><strong>Họ tên:</strong> <%= nguoitra.getHoTen() %></p>
    <p><strong>Mã thẻ:</strong> <%= mathe %></p>
</div>

<div class="content">
    <!-- Bảng tài liệu chưa trả -->
    <div class="table-container">
        <h4>Tài liệu đang mượn chưa trả</h4>
        <table border="1">
            <tr>
                <th>ID</th>
                <th>Tên tài liệu</th>
                <th>Ngày hẹn trả</th>
                <th>Tình trạng ban đầu</th>
                <th>Thao tác</th>
            </tr>
            <%
                String action = request.getParameter("action");
                if((action == null)||(action.trim().length() ==0)) // goi tu trang Chon ban doc
                {
                    TaiLieuMuon764DAO taiLieuMuonDAO = new TaiLieuMuon764DAO();
                    taiLieuChuaTra = taiLieuMuonDAO.getTaiLieuMuonChuaTraTheoId(nguoitra.getId());
                    session.setAttribute("tailieuchuatra", taiLieuChuaTra);

                    phieuTra.setDsTra(new ArrayList<TaiLieuMuon764>());
                    session.setAttribute("phieutra", phieuTra);
                }
                else if(action.equalsIgnoreCase("xoa")) // goi tu trang nay
                {
                    phieuTra = (PhieuTra764) session.getAttribute("phieutra");
                    taiLieuChuaTra = (List<TaiLieuMuon764>) session.getAttribute("tailieuchuatra");
                    String id = request.getParameter("id");
                    for(TaiLieuMuon764 taiLieuMuon : phieuTra.getDsTra()) {
                        if(taiLieuMuon.getId() == Integer.parseInt(id)) {
                            phieuTra.getDsTra().remove(taiLieuMuon);
                            taiLieuMuon.setPhieuphat(null);
                            taiLieuMuon.setTrangthai(false);
                            taiLieuMuon.setTinhtrangsau(-1);
                            taiLieuChuaTra.add(taiLieuMuon);
                            break;
                        }
                    }
                    session.setAttribute("phieutra", phieuTra);
                    session.setAttribute("tailieuchuatra", taiLieuChuaTra);
                } else if(action.equalsIgnoreCase("them")) {

                }

                for (TaiLieuMuon764 taiLieuMuon : taiLieuChuaTra) {
            %>
            <tr>
                <td><%=taiLieuMuon.getId()%></td>
                <td><%=taiLieuMuon.getTailieu().getTen()%></td>
                <td><%=taiLieuMuon.getNgayhentra()%></td>
                <td><%=taiLieuMuon.getTinhtrangbandau()%></td>
                <%
                    String taiLieuMuonJson = gson.toJson(taiLieuMuon);
                %>
                <td><button onclick="location.href='gdXulytienphat764.jsp?tailieumuon=<%=URLEncoder.encode(taiLieuMuonJson, "UTF-8")%>'">Trả</button></td>
            </tr>
            <%} %>
        </table>
    </div>

    <!-- Bảng tài liệu dự kiến trả -->
    <div class="table-container">
        <h4>Tài liệu dự kiến trả</h4>
        <table border="1">
            <tr>
                <th>ID</th>
                <th>Tên tài liệu</th>
                <th>Số ngày quá hạn</th>
                <th>Mức độ hư hỏng</th>
                <th>Tiền phạt</th>
                <th>X</th>
            </tr>
            <%
                for(TaiLieuMuon764 taiLieuMuon : phieuTra.getDsTra()) {
                    int songayquahan = 0;
            %>
            <tr>
                <td><%=taiLieuMuon.getId()%></td>
                <td><%=taiLieuMuon.getTailieu().getTen()%></td>
                <td><%=taiLieuMuon.getId()%></td>
                <td><%=taiLieuMuon.getTinhtrangsau() - taiLieuMuon.getTinhtrangbandau()%></td>
                <td><%=taiLieuMuon.getPhieuphat().getTienphat()%></td>
                <tb><button onclick="location.href='gdTratailieu764.jsp?action=xoa&&id=<%=taiLieuMuon.getId()%>'">X</button></tb>
            </tr>
            <% } %>
        </table>

        <div class="total">
            <strong>Tổng tiền phạt:</strong><%= phieuTra.getTongtienphat()%>  VNĐ
        </div>
        <button style="margin-top: 8px">Xác nhận</button>
    </div>
</div>
<%
    } else {
%>
    }
    <div class="result no-result">
        <p>Opps. Vui lòng thử lại sau.</p>
</div>
<%
    }
    %>
</body>
</html>