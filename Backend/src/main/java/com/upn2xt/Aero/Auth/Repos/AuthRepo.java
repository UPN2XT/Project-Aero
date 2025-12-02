package com.upn2xt.Aero.Auth.Repos;

public interface AuthRepo {

    Integer hrLogin (Integer id, String password);

    Integer employeeLogin (Integer id, String password);
}
