<%-- 
    Document   : reporte.jsp
    Created on : 8 nov. 2021, 11:23:51
    Author     : diego
--%>
<%@page import="org.apache.poi.xssf.usermodel.XSSFCellStyle"%>
<%@page import="java.io.OutputStream"%>
<%@page import="java.io.ByteArrayOutputStream"%>
<%@page import="org.apache.poi.ss.usermodel.*"%>
<%@page import="org.apache.poi.xssf.streaming.*"%>
<%@page import="java.sql.SQLException"%>
<%@page import="com.itextpdf.text.DocumentException"%>
<%@page import="com.itextpdf.text.Font.FontFamily"%>
<%@page import="com.itextpdf.text.Font"%>
<%@page import="com.itextpdf.text.Phrase"%>
<%@page import="com.itextpdf.text.pdf.PdfPCell"%>
<%@page import="com.itextpdf.text.pdf.PdfPTable"%>
<%@page import="com.itextpdf.text.Paragraph"%>
<%@page import="com.itextpdf.text.pdf.PdfWriter"%>
<%@page import="com.itextpdf.text.PageSize"%>
<%@page import="com.itextpdf.text.Document"%>
<%@page import="com.tp.reportesweb.dao.Conexion"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.Connection"%>
<%
    String tipo = request.getParameter("type");
    String pais = request.getParameter("pais");
    String region = request.getParameter("region");
    Connection conexion = new Conexion().getConnection();
    PreparedStatement ps = null;
    ResultSet resultSet = null;
    if(tipo.equals("pdf")){
        response.setContentType("application/pdf");
        Font titulo = new Font(FontFamily.UNDEFINED, 14, Font.BOLD);
        Font textoBold = new Font(FontFamily.UNDEFINED, 11, Font.BOLD);
        Font texto = new Font(FontFamily.UNDEFINED, 11, Font.NORMAL);
        Document document = new Document(PageSize.A4, 30, 30, 50, 30);
        try{
            document.addTitle("reporte del pais");
            document.addCreator("Diego");
            document.addCreator("Diego");
            PdfWriter.getInstance(document, response.getOutputStream());
            document.open();
            Paragraph docTitle = new Paragraph("Reporte del Pais ("+pais.toUpperCase()+")", titulo);
            Paragraph sub = new Paragraph("Region: "+region, textoBold);
            docTitle.setIndentationLeft(155);
            sub.setIndentationLeft(200);
            document.add(docTitle);
            document.add(sub);
            document.add(new Phrase("\n", texto));
            //se crea una tabla con 4 columnas
            PdfPTable table = new PdfPTable(4);
            table.addCell(new PdfPCell(new Phrase("ciudad", texto)));
            table.addCell(new PdfPCell(new Phrase("population", texto)));
            table.addCell(new PdfPCell(new Phrase("pais", texto)));
            table.addCell(new PdfPCell(new Phrase("region", texto)));

            ps = conexion.prepareStatement(
                "SELECT ciudad.name as ciudad, ciudad.population as population, pais.name as pais, pais.region as region FROM city ciudad "+
                    "INNER JOIN country pais ON ciudad.CountryCode = pais.code "+
                        "WHERE pais.region = ? " + 
                        "AND pais.name LIKE ? ORDER BY pais.name");
            ps.setString(1, region);
            ps.setString(2, "%"+pais+"%");
            resultSet = ps.executeQuery();
            while(resultSet.next()){
                table.addCell(new PdfPCell(new Phrase(new String(resultSet.getString("ciudad").getBytes("Cp1252"), "UTF-8"), texto)));
                table.addCell(new PdfPCell(new Phrase(new String(resultSet.getString("population").getBytes("Cp1252"), "UTF-8"), texto)));
                table.addCell(new PdfPCell(new Phrase(new String(resultSet.getString("pais").getBytes("Cp1252"), "UTF-8"), texto)));
                table.addCell(new PdfPCell(new Phrase(new String(resultSet.getString("region").getBytes("Cp1252"), "UTF-8"), texto)));
            }
            document.add(table);
        }catch(DocumentException e){
            //document exeptions
        }catch(SQLException e){
            //
        }finally{
            document.close();
            if(resultSet != null) resultSet.close();
            if(ps != null) ps.close();
            if(conexion != null) conexion.close();                          
        }
         
    }else if(tipo.equals("excel")){
        response.setContentType("application/ms-excel");
        SXSSFWorkbook libro = new SXSSFWorkbook(50);
        SXSSFSheet hoja = libro.createSheet();
        XSSFCellStyle yellow = (XSSFCellStyle) libro.createCellStyle();
        yellow.setFillForegroundColor(IndexedColors.YELLOW.index);
        yellow.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        XSSFCellStyle green = (XSSFCellStyle) libro.createCellStyle();
        green.setFillForegroundColor(IndexedColors.GREEN.index);
        green.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        int nroColumna = 0;
        int nroFila = 0;
        //se crea una fila dentro de la hoja
        SXSSFRow row = hoja.createRow(nroFila);
        //se crea una celda dentro de la fila
        SXSSFCell cell = row.createCell(nroColumna);
        cell.setCellValue("ciudad");
        cell = row.createCell(++nroColumna);
        cell.setCellValue("population");
        cell = row.createCell(++nroColumna);
        cell.setCellValue("pais");
        cell = row.createCell(++nroColumna);
        cell.setCellValue("region");
        ps = conexion.prepareStatement(
                "SELECT ciudad.name as ciudad, ciudad.population as population, pais.name as pais, pais.region as region FROM city ciudad "+
                    "INNER JOIN country pais ON ciudad.CountryCode = pais.code "+
                        "WHERE pais.region = ? " + 
                        "AND pais.name LIKE ? ORDER BY pais.name");
            ps.setString(1, region);
            ps.setString(2, "%"+pais+"%");
            resultSet = ps.executeQuery();
        while(resultSet.next()){
            nroFila++;
            nroColumna = 0;
            row = hoja.createRow(nroFila);
            cell = row.createCell(nroColumna);
            cell.setCellValue(new String(resultSet.getString("ciudad").getBytes("Cp1252"), "UTF-8"));
            cell = row.createCell(++nroColumna);
            String population = new String(resultSet.getString("population").getBytes("Cp1252"), "UTF-8");
            cell.setCellValue(population);
            try{
                long poblacion = Long.parseLong(population);
                if(poblacion > 5000000)
                    cell.setCellStyle(yellow);
                else if(poblacion < 100000)
                    cell.setCellStyle(green);
            }catch(Exception e){}
            cell = row.createCell(++nroColumna);
            cell.setCellValue(new String(resultSet.getString("pais").getBytes("Cp1252"), "UTF-8"));
            cell = row.createCell(++nroColumna);
            cell.setCellValue(new String(resultSet.getString("region").getBytes("Cp1252"), "UTF-8"));
        }
        ByteArrayOutputStream stream = new ByteArrayOutputStream();
        libro.write(stream);
        byte[] outArray = stream.toByteArray();
        response.setContentLength(outArray.length);
        response.setHeader("Expires:", "0");
        response.setHeader("Content-Disposition", "attachment; filename=reporte-"+pais+".xls");
        OutputStream outStream = response.getOutputStream();
        outStream.write(outArray);
        outStream.flush();
    }
%>
