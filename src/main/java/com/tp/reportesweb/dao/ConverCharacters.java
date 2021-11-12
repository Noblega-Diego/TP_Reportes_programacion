/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.tp.reportesweb.dao;

import java.io.UnsupportedEncodingException;

/**
 *
 * @author diego
 */
public class ConverCharacters {
    public static String UTF8 ="UTF-8";
    public static String convertTo(String type, String value){
        try {
            if(type.equals(type))    
                return new String(value.getBytes("Cp1252"), "UTF-8");
            else
                return value;
        } catch (UnsupportedEncodingException ex) {
            return value;
        }
    }
}
