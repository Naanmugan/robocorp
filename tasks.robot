*** Settings ***
Documentation       Order robot from RobotSpareBin Industries Inc.
...                 Save the Order Invoice as PDF file.
...                 Take screenshot of the robot image.
...                 Attach the image in PDF file.
...                 Create a .zip file containing all the PDF files.

Library             RPA.Browser.Selenium
Library             RPA.HTTP
Library             RPA.PDF
Library             RPA.Tables
Library             BuiltIn
Library             OperatingSystem
Library             Screenshot
Library             RPA.Archive
Library             RPA.Dialogs
Library             RPA.Robocorp.Vault


*** Variables ***
${URL}          https://robotsparebinindustries.com
${Username}     maria
${Password}     thoushallnotpass


*** Tasks ***
Order Robots From RobotSpareBin Website
    Download CSV File
    Launch RobotSpareBin Website
    Click Order Your Robot
    Read CSV File,Enter Data,Submit The Form
    Create ZIP Folder
    Logout And Close The Browser


*** Keywords ***
Download CSV File
    Add Heading    Enter the URL to download CSV file
    Add text input    URL    Enter the URL
    ${download_link}=    Run dialog
    Download    ${download_link.URL}    ${OUTPUT_DIR}${/}    overwrite=True

Launch RobotSpareBin Website
    ${Read_Valut_Value}=    Get Secret    Link
    Open Available Browser    ${Read_Valut_Value}[Link]    maximized=True
    Input Text    xpath=//input[@id='username']    ${Username}
    Input Password    xpath=//input[@id='password']    ${Password}
    Click Button    xpath=//button[contains(text(),'Log in')]
    Wait Until Page Contains Element    xpath=//button[contains(text(),'Log out')]

Click Order Your Robot
    Click Link    xpath=//a[@class='nav-link']
    Sleep    1
    Click Button    xpath=//button[contains(text(),'OK')]

Read CSV File,Enter Data,Submit The Form
    Empty Directory    ${OUTPUT_DIR}${/}Receipts
    Empty Directory    ${OUTPUT_DIR}${/}Robot_Image
    ${Table}=    Read table from CSV    ${OUTPUT_DIR}${/}orders.csv    header=True
    #Log    ${Table}[1][4]
    FOR    ${element}    IN    @{Table}
        #${i}=    Set Variable    1
        #Log    ${element}[Order number]
        #Log    ${element}[Head]
        #Log    ${element}[Body]
        #Log    ${element}[Legs]
        #Log    ${element}[Address]
        #${i} += 1
        Fill Form    ${element}
        Save Receipt And Robot Image    ${element}
        Order Another Robot
    END

Fill Form
    [Arguments]    ${data}
    Select From List By Value    xpath=//select[@id='head']    ${data}[Head]
    Select Radio Button    body    ${data}[Body]
    Input Text    xpath=//input[@class='form-control']    ${data}[Legs]
    Input Text    xpath=//input[@name='address']    ${data}[Address]
    Wait Until Keyword Succeeds    10x    5s    Click Preview Button
    Wait Until Keyword Succeeds    10x    5s    Click Order Button    ${data}

Click Preview Button
    Click Button    xpath=//button[@id='preview']
    Wait Until Element Is Visible    xpath=//div[@id='robot-preview-image']

Click Order Button
    [Arguments]    ${file_data}
    Click Button    xpath=//button[@id='order']
    Wait Until Element Is Visible    xpath=//button[@id="order-another"]

Order Another Robot
    Click Button    xpath=//button[@id="order-another"]
    Wait Until Element Is Visible    xpath=//button[contains(text(),'OK')]
    Click OK

Click OK
    Click Button    xpath=//button[contains(text(),'OK')]

Save Receipt And Robot Image
    [Arguments]    ${file_data}
    ${Receipt_HTML}=    Get Element Attribute    xpath=//div[@id='receipt']    outerHTML
    #${File_Name}=    Get Text    xpath=//p[@class='badge badge-success']
    Html To Pdf    ${Receipt_HTML}    ${OUTPUT_DIR}${/}Receipts${/}${file_data}[Order number].pdf
    #${File_Name}=    Get Text    xpath=//p[@class='badge badge-success']
    Capture Element Screenshot
    ...    xpath=//div[@id="robot-preview-image"]
    ...    ${OUTPUT_DIR}${/}Robot_Image${/}${file_data}[Order number].png
    Open Pdf    ${OUTPUT_DIR}${/}Receipts${/}${file_data}[Order number].pdf
    ${list}=    Create List    ${OUTPUT_DIR}${/}Robot_Image${/}${file_data}[Order number].png
    Add Files To Pdf
    ...    ${list}
    ...    ${OUTPUT_DIR}${/}Receipts${/}${file_data}[Order number].pdf    append=True
    #Close Pdf    ${OUTPUT_DIR}${/}Receipts${/}${file_data}[Order number].pdf

Create ZIP Folder
    Archive Folder With Zip    ${OUTPUT_DIR}${/}Receipts    Order_Receipts.zip    recursive=True    include=*.pdf

Logout And Close The Browser
    Click Button    xpath=//button[@id='logout']
    Close Browser
