import stream_chat
from app.schema import AuthModel, ConfirmSignup, CreateUser, UserLogin
from app.settings import settings as app_settings
from fastapi import Depends, FastAPI, Response
from fastapi_cloudauth.cognito import CognitoClaims, CognitoCurrentUser
from pycognito import Cognito

app = FastAPI()

get_current_user = CognitoCurrentUser(
    region=app_settings.COGNITO_AWS_REGION,
    userPoolId=app_settings.COGNITO_USER_POOL_ID,
    client_id=app_settings.COGNITO_CLIENT_ID,
)

cognito = Cognito(
    user_pool_id=app_settings.COGNITO_USER_POOL_ID,
    client_id=app_settings.COGNITO_CLIENT_ID,
    client_secret=app_settings.COGNITO_CLIENT_SECRET,
)

stream_chat_client = stream_chat.StreamChat(
    api_key=app_settings.STREAM_CHAT_API_KEY,
    api_secret=app_settings.STREAM_CHAT_ACCESS_KEY,
)


@app.post("/signup", status_code=201)
async def signup(user_details: CreateUser):
    cognito.username = user_details.username
    cognito.set_base_attributes(email=user_details.email)
    response = cognito.register(
        username=user_details.username, password=user_details.password
    )
    return response


@app.post("/signup/confirm")
async def confirm_signup(signup_details: ConfirmSignup, response: Response):
    cognito.username = signup_details.username
    try:
        cognito.confirm_sign_up(
            confirmation_code=signup_details.confirmation_code,
            username=signup_details.username,
        )
        stream_chat_client.upsert_user(dict(id=cognito.username))
        return {"message": "success"}
    except Exception as e:
        response.status_code = 400
        return e.response.get("message")


@app.post("/login")
async def login(user_details: UserLogin, response: Response):
    cognito.username = user_details.username
    try:
        cognito.authenticate(password=user_details.password)
        stream_token = stream_chat_client.create_token(cognito.username)
        auth_details = dict(
            id_token=cognito.id_token,
            refresh_token=cognito.refresh_token,
            access_token=cognito.access_token,
            stream_token=stream_token,
        )
        return auth_details
    except Exception as e:
        response.status_code = 403
        return e.response.get("message")


@app.post("/logout")
async def logout(auth_details: AuthModel):
    cognito = Cognito(
        user_pool_id=app_settings.COGNITO_USER_POOL_ID,
        client_id=app_settings.COGNITO_CLIENT_ID,
        client_secret=app_settings.COGNITO_CLIENT_SECRET,
        id_token=auth_details.id_token,
        refresh_token=auth_details.refresh_token,
        access_token=auth_details.access_token,
        username=auth_details.username,
    )
    cognito.logout()


@app.get("/")
async def root(current_user: CognitoClaims = Depends(get_current_user)):
    return {"message": f"Hello, {current_user.username}"}
