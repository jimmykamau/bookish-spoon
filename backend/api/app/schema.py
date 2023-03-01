from pydantic import BaseModel


class CreateUser(BaseModel):
    email: str
    username: str
    password: str


class ConfirmSignup(BaseModel):
    confirmation_code: str
    username: str


class UserLogin(BaseModel):
    username: str
    password: str


class AuthModel(BaseModel):
    id_token: str
    refresh_token: str
    access_token: str
    username: str
