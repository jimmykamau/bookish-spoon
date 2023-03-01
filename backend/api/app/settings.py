import ast
from functools import lru_cache
from os import environ

from dotenv import load_dotenv
from pydantic import BaseSettings

load_dotenv()


def get_list(text):
    return [item.strip() for item in text.split(",")]


def get_bool_from_env(name, default_value):
    if name in environ:
        value = environ[name]
        try:
            return ast.literal_eval(value)
        except ValueError as e:
            raise ValueError("{} is an invalid value for {}".format(value, name)) from e
    return default_value


class Settings(BaseSettings):
    DEBUG = get_bool_from_env("DEBUG", False)
    DATABASE_URL: str
    SECRET_KEY: str

    COGNITO_CLIENT_ID: str
    COGNITO_CLIENT_SECRET: str
    COGNITO_USER_POOL_ID: str
    COGNITO_AWS_REGION: str

    STREAM_CHAT_API_KEY: str
    STREAM_CHAT_ACCESS_KEY: str

    class Config:
        env_file = ".env"


@lru_cache()
def get_settings():
    return Settings()


settings = get_settings()
