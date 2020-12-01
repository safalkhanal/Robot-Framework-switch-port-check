*** Settings ***
Library           SeleniumLibrary
Library           Telnet
Library           Collections
Library           RPA.Email.ImapSmtp    smtp_server=smtp.gmail.com    smtp_port=587

*** Variables ***
${URL}            xxx.xxx.xxx.xxx
${login_un}       admin
${login_pwd}      password
@{portlist}
${USER}  sender@gmail.com
${PASS}  sender_password
${mail}  receiver@gmail.com
${subject}  Test case result
${index}    0

*** Test Cases ***
EveLoginTest
    Log    Login to EVE
    Open Browser    ${URL}    chrome
    Set Browser Implicit Wait    10
    LoginEVE
    TelnetLogin
    Close Browser

*** Keywords ***
LoginEVE
    Input Text    xpath:/html/body/div/div/div[3]/div[1]/input    ${login_un}
    Input Password    xpath:/html/body/div/div/div[3]/div[2]/input    ${login_pwd}
    Click Button    id=btnlogin
    Log    Login to EVE is successful

TelnetLogin
    @{port_down}    Create List
    FOR    ${portlist}    IN    @{portlist}
        ${status}=    Run Keyword And Return Status    Open Connection    ${URL}     port=${portlist}    prompt=$
        Run Keyword If    ${status}==True   Log    Login to router with port ${portlist} is successful and it's services are up
        Run Keyword If  ${status}==False  run keywords
        ...    Log    Login to router with port ${portlist} is unsuccessful and it's services are down
        ...    AND    Insert Into List  ${port_down}   ${index}  ${portlist}
        ...    AND    Evaluate  ${index}+1
        Close Connection
    END
    Set Global Variable  ${port_down}

PortDown
    ${length}=  Get length    ${port_down}
    Run Keyword If  ${length} > 0   run keywords
        Log    Login to router with port @{port_down} is unsuccessful and this port is down
        Authorize    account=${USER}    password=${PASS}
        Send Message    sender=${USER}
        ...    recipients=${mail}
        ...    subject=${subject}
        ...    body= This is a test message. These ports are down @{port_down}.

