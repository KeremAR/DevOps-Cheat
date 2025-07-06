# AWS Serverless Hands-On Labs

This document details the step-by-step solutions for hands-on labs focused on AWS Serverless services like API Gateway and Lambda.

---

## Task: Integrating API Gateway with a Lambda Function (CLI Method)

*This task walks through the process of integrating an existing AWS API Gateway with a pre-configured AWS Lambda function. The entire process must be completed using the AWS Command Line Interface (CLI).*

### Step 1: Task Analysis & Strategy

The objective is to connect an existing API Gateway (`8a702w0i37`) to an existing Lambda function (`cmtr-zdv1y551-api-gwlp-lambda-contacts`). Specifically, the route with ID `ft1akbl` (which corresponds to `GET /contacts`) must be configured to trigger the Lambda function. This is a common serverless pattern where API Gateway provides the HTTP endpoint and Lambda provides the business logic.

The strategy for accomplishing this via the CLI involves three distinct steps:

1.  **Create the Integration:** First, we must define the integration itself. This acts as the "glue" between the API Gateway and the Lambda function. We will use the `aws apigatewayv2 create-integration` command to create a Lambda proxy integration, which requires us to first retrieve the full ARN of the Lambda function.
2.  **Update the Route:** After creating the integration, the next step is to tell the specific route (`ft1akbl`) to use it. An integration can exist without being used, so this step is essential for connecting it to the `GET /contacts` endpoint. We will use the `aws apigatewayv2 update-route` command to set the integration as the route's `target`.
3.  **Grant Permissions:** For security reasons, AWS services cannot invoke each other by default. We must explicitly grant the API Gateway service permission to invoke our Lambda function. This is done by adding a resource-based policy to the Lambda function using the `aws lambda add-permission` command. Without this step, API Gateway would return a 5xx error.

### Step 2: Execution via AWS CLI (PowerShell)

The following PowerShell commands were used to execute the task. It is assumed the AWS CLI has been configured with the provided credentials.

1.  **Define Variables and Get Lambda ARN:**
    *   First, we define variables for the known resource IDs and names to make the script reusable and easier to read. Then, we fetch the full ARN of the Lambda function, which is required for the integration step.
    ```powershell
    # Define resource names and IDs from the lab description
    $apiId = "8a702w0i37"
    $routeId = "ft1akbl"
    $functionName = "cmtr-zdv1y551-api-gwlp-lambda-contacts"
    $region = "us-east-1"

    # Get the full ARN of the Lambda function
    $functionArn = (aws lambda get-function --function-name $functionName --query "Configuration.FunctionArn" --output text)
    Write-Host "Lambda Function ARN: $functionArn"
    ```

2.  **Create the API Gateway Integration:**
    *   This command creates the integration entity. We specify the `api-id`, the `integration-type` as `AWS_PROXY` (standard for Lambda), and the `integration-uri` as the Lambda function's ARN. We capture the returned `IntegrationId` for the next step.
    ```powershell
    $integrationId = (aws apigatewayv2 create-integration --api-id $apiId --integration-type AWS_PROXY --payload-format-version 2.0 --integration-uri $functionArn --query "IntegrationId" --output text)
    Write-Host "Created Integration ID: $integrationId"
    ```

3.  **Update the Route to Use the Integration:**
    *   This command modifies the existing route (`ft1akbl`), corrects its path to `/contacts`, and sets its target to the integration we just created. The target format must be `integrations/<IntegrationId>`.
    ```powershell
    aws apigatewayv2 update-route --api-id $apiId --route-id $routeId --route-key "GET /contacts" --target "integrations/$integrationId"
    ```

4.  **Grant API Gateway Permission to Invoke Lambda:**
    *   This is the final and critical step. We need the AWS Account ID to construct a `source-arn` that scopes the permission correctly. This command allows any route within our specific API Gateway to invoke the Lambda function.
    ```powershell
    # Get the AWS Account ID
    $accountId = (aws sts get-caller-identity --query "Account" --output text)

    # Construct the Source ARN to grant permission to the API Gateway
    $sourceArn = "arn:aws:execute-api:${region}:${accountId}:${apiId}/*"

    # Add the resource-based policy to the Lambda function
    aws lambda add-permission --function-name $functionName --statement-id "apigateway-invoke-permission-cli" --action lambda:InvokeFunction --principal apigateway.amazonaws.com --source-arn $sourceArn
    ```

### Step 3: Verification

To verify that the integration is working correctly, you need to call the public API endpoint.

1.  **Get the Stage Name:**
    *   First, identify the deployment stage for the API. When a stage is not named `$default`, its name must be included in the invocation URL.
    ```powershell
    $stageName = (aws apigatewayv2 get-stages --api-id $apiId --query "Items[0].StageName" --output text)
    Write-Host "API Stage Name: $stageName"
    ```

2.  **Construct the Invocation URL:**
    *   The URL for a named stage follows the format: `https://{api-id}.execute-api.{region}.amazonaws.com/{stage-name}/{route}`.
    *   The full URL is: `https://$apiId.execute-api.$region.amazonaws.com/$stageName/contacts`

3.  **Test the Endpoint:**
    *   You can use a command-line tool like `curl` or simply paste the URL into a web browser. The URL needs to be constructed with the stage name.
    ```powershell
    $invokeUrl = "https://$apiId.execute-api.$region.amazonaws.com/$stageName/contacts"
    curl $invokeUrl
    ```

4.  **Confirm the Result:**
    *   The command should return a JSON array with three contact objects, exactly as specified in the lab description. This confirms that the API Gateway successfully received the request, invoked the Lambda function, and returned its response.
    ```json
    [
      {
        "id": 1,
        "name": "Elma Herring",
        "email": "elmaherring@unq.com",
        "phone": "+1 (913) 497-2020"
      },
      {
        "id": 2,
        "name": "Bell Burgess",
        "email": "bellburgess@unq.com",
        "phone": "+1 (887) 478-2693"
      },
      {
        "id": 3,
        "name": "Hobbs Ferrell",
        "email": "hobbsferrell@unq.com",
        "phone": "+1 (862) 581-3022"
      }
    ]
    ```

## Task: Implement Simple Lambda Function with SNS Integration (GUI Method)

*This task demonstrates how to build an event-driven workflow using the AWS Management Console. It involves creating and configuring an SNS topic, an SQS queue, an IAM Role, and a Lambda function that integrates with a third-party API and publishes results to SNS.*

### Step 1: Task Analysis & Strategy

The objective is to create a serverless application that takes an IP address, queries the `ipinfo.io` service to find the corresponding city, and then publishes this information to an SNS topic. This topic should then distribute the message to both an email address and an SQS queue.

The strategy is to build the components in a logical order, starting from the data destination (SNS/SQS) and working backwards to the data source (Lambda).

1.  **Create SNS Topic:** This is the central messaging hub.
2.  **Create SQS Queue:** This will be one of the subscribers to the SNS topic.
3.  **Create Subscriptions:** Subscribe both the user's email and the SQS queue to the SNS topic. This requires a confirmation step for the email.
4.  **Create IAM Role:** Define the permissions the Lambda function will need (`SNS:Publish` and basic execution logging).
5.  **Create and Configure Lambda Function:**
    *   Write the Python code to handle the incoming event, call the external API, and publish to SNS.
    *   Using an environment variable for the SNS topic ARN is a best practice to avoid hardcoding.
    *   Attach the previously created IAM role.
6.  **Test and Verify:** Invoke the Lambda with a test payload and check all endpoints (email and SQS) to ensure the message has been delivered correctly.

### Step 2: Execution via AWS Management Console

The following steps were performed in the `us-east-1` region.

1.  **Create the SNS Topic:**
    *   Navigate to the **Simple Notification Service (SNS)** dashboard.
    *   In the left pane, click **Topics**, then **Create topic**.
    *   **Type:** Select **Standard**.
    *   **Name:** Enter `cmtr-zdv1y551-sns`.
    *   Scroll to the bottom and click **Create topic**.
    *   Once created, copy the **ARN** of the topic. You will need it later.

2.  **Create the SQS Queue:**
    *   Navigate to the **Simple Queue Service (SQS)** dashboard.
    *   Click **Create queue**.
    *   **Type:** Select **Standard**.
    *   **Name:** Enter `cmtr-zdv1y551-sqs`.
    *   Leave all other settings as their default values and click **Create queue**.

3.  **Create SNS Subscriptions:**
    *   Navigate back to the **SNS** dashboard and click on your topic, `cmtr-zdv1y551-sns`.
    *   Click the **Subscriptions** tab, then click **Create subscription**.
    *   **Create Email Subscription:**
        *   **Protocol:** Select **Email**.
        *   **Endpoint:** Enter `kerem_ar@epam.com`.
        *   Click **Create subscription**.
        *   **Action Required:** You must check your email inbox for a message from "AWS Notifications" and click the **"Confirm subscription"** link. The subscription will remain in a "Pending confirmation" state until you do this.
    *   **Create SQS Subscription:**
        *   Click **Create subscription** again.
        *   **Protocol:** Select **Amazon SQS**.
        *   **Endpoint:** Select the ARN of the `cmtr-zdv1y551-sqs` queue from the dropdown list.
        *   Click **Create subscription**. SNS will automatically handle the permissions required to send messages to the SQS queue.

4.  **Create the IAM Role for Lambda:**
    *   Navigate to the **IAM** dashboard.
    *   In the left pane, click **Roles**, then **Create role**.
    *   **Trusted entity type:** Select **AWS service**.
    *   **Use case:** Select **Lambda**. Click **Next**.
    *   **Add permissions:**
        *   In the search box, find and select the checkbox for `AmazonSNSFullAccess`.
        *   In the search box, find and select the checkbox for `AWSLambdaBasicExecutionRole`.
    *   Click **Next**.
    *   **Role name:** Enter `cmtr-zdv1y551-lambda_sns_role`.
    *   Click **Create role**.

5.  **Create and Configure the Lambda Function:**
    *   Navigate to the **Lambda** dashboard.
    *   Click **Create function**.
    *   **Author from scratch**.
    *   **Function name:** `cmtr-zdv1y551-lambda`.
    *   **Runtime:** Select **Python 3.9** (or a newer Python version).
    *   **Architecture:** Leave as `x86_64`.
    *   **Permissions:** Expand "Change default execution role". Select **Use an existing role** and choose `cmtr-zdv1y551-lambda_sns_role` from the list.
    *   Click **Create function**.
    *   **Add Lambda Code:**
        *   In the "Code source" editor, replace the default code with the following Python script:
        ```python
        import json
        import urllib.request
        import boto3
        import os

        # Initialize the SNS client
        sns_client = boto3.client('sns')
        # Get the SNS Topic ARN from the environment variable
        SNS_TOPIC_ARN = os.environ.get('SNS_TOPIC_ARN')

        def lambda_handler(event, context):
            # 1. Get IP address from the incoming event
            ip_address = event.get('ip_address')
            if not ip_address:
                return {
                    'statusCode': 400,
                    'body': json.dumps('Error: ip_address not provided in the event.')
                }

            # 2. Make a request to the IPinfo API
            try:
                url = f"https://ipinfo.io/{ip_address}/json"
                with urllib.request.urlopen(url) as response:
                    data = json.loads(response.read().decode())
                city = data.get('city', 'Unknown')
            except Exception as e:
                print(f"Error calling IPinfo API: {e}")
                city = "Error_Fetching_City"

            # 3. Prepare the message payload for SNS
            message_payload = {
                "ip_address": ip_address,
                "city": city
            }

            # 4. Publish the message to the SNS topic
            try:
                sns_client.publish(
                    TopicArn=SNS_TOPIC_ARN,
                    Message=json.dumps(message_payload),
                    Subject=f"City information for {ip_address}"
                )
                print(f"Successfully published message to SNS: {message_payload}")
            except Exception as e:
                print(f"Error publishing to SNS: {e}")
                return {
                    'statusCode': 500,
                    'body': json.dumps('Failed to publish message to SNS.')
                }
                
            # 5. Return a success response
            return {
                'statusCode': 200,
                'body': json.dumps(f"Successfully processed IP {ip_address} and published to SNS.")
            }
        ```
    *   **Add Environment Variable:**
        *   Go to the **Configuration** tab, then click **Environment variables**.
        *   Click **Edit**, then **Add environment variable**.
        *   **Key:** `SNS_TOPIC_ARN`.
        *   **Value:** Paste the ARN of your `cmtr-zdv1y551-sns` topic that you copied in Step 1.
        *   Click **Save**.
    *   Click the **Deploy** button above the code editor to save your changes.

### Step 3: Verification

1.  **Configure a Test Event:**
    *   In the Lambda function view, click the **Test** tab.
    *   Select **Create new event**.
    *   **Event name:** `TestIPEvent`.
    *   **Event JSON:** Enter the following payload:
        ```json
        {
          "ip_address": "8.8.8.8"
        }
        ```
    *   Click **Save**.

2.  **Invoke the Lambda Function:**
    *   With the `TestIPEvent` selected, click the **Test** button.

3.  **Check Results:**
    *   **Lambda Execution:** You should see a "succeeded" message in the execution results tab. The logs should show "Successfully published message to SNS".
    *   **Email:** Check your `kerem_ar@epam.com` inbox. You should have an email from SNS with the subject "City information for 8.8.8.8" and a body containing `{"ip_address": "8.8.8.8", "city": "Mountain View"}`.
    *   **SQS Queue:**
        *   Navigate to the **SQS** dashboard and select the `cmtr-zdv1y551-sqs` queue.
        *   Click **Send and receive messages**.
        *   In the "Receive messages" section, click **Poll for messages**.
        *   A message should appear. Click on its ID to view the body, which should contain the same JSON payload as the email.

This confirms that the entire workflow is functioning correctly.
