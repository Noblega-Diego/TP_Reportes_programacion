<%-- 
    Document   : formulario
    Created on : 8 nov. 2021, 09:53:26
    Author     : diego
--%>

<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.Connection"%>
<%@page import="com.tp.reportesweb.dao.Conexion"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Generar reporte de pais</title>
    </head>
    <body>
        <h1>Generar reporte de pais</h1>
        <form action="reporte.jsp">
            <div>
                <label>Pais</label>
                <input type="text" name="pais" id="inpais"/>
            </div>    
            <div>
                <label>Seleccionar la region</label>
                <select name="region">
                    <%
                        String message = null;
                        Connection conexion = new Conexion().getConnection();
                        PreparedStatement ps = null;
                        ResultSet resultSet = null;
                        try{
                        if(conexion != null){
                            ps =  conexion.prepareStatement("SELECT DISTINCT region FROM country");
                            resultSet = ps.executeQuery();
                            while(resultSet.next()){
                                String country = resultSet.getString(1);
                                out.print("<option value='"+country+"'>"+country+"</option>");
                            }
                        }
                        }catch(Exception e){
                            message = "no se han podido cargar las regiones: "+ e;
                            
                        }finally{
                            if(resultSet != null) resultSet.close();
                            if(ps != null) ps.close();
                            if(conexion != null) conexion.close();                          
                        }
                    %>
                </select>
                    <% if(message != null) out.write("<span>"+message+"</span>"); %>
            </div>
            <div>
                <button type="submit" name="type" value="pdf">Generate pdf</button>
                <button type="submit" name="type" value="excel">Generate excel</button>      
            </div>
        </form>
    </body>
</html>
