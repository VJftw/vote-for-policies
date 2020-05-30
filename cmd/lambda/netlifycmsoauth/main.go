package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/ssm"
	ginadapter "github.com/awslabs/aws-lambda-go-api-proxy/gin"
	"github.com/gin-gonic/gin"
	"github.com/markbates/goth"
	"github.com/markbates/goth/gothic"
	"github.com/markbates/goth/providers/github"
)

var ginLambda *ginadapter.GinLambda

func init() {
	sess := session.Must(session.NewSession())
	ssmSvc := ssm.New(sess)

	ssmParamPath := os.Getenv("GITHUB_SECRET_SSM_PATH")

	paramRes, err := ssmSvc.GetParameter(&ssm.GetParameterInput{
		Name:           aws.String(ssmParamPath),
		WithDecryption: aws.Bool(true),
	})
	if err != nil {
		panic(err)
	}

	githubSecret := aws.StringValue(paramRes.Parameter.Value)

	host := os.Getenv("HOST")

	TargetOrigin = os.Getenv("TARGET_ORIGIN")
	goth.UseProviders(
		github.New(
			os.Getenv("GITHUB_ID"), githubSecret,
			fmt.Sprintf("https://%s/auth/github/callback", host),
			"repo",
		),
	)

	// stdout and stderr are sent to AWS CloudWatch Logs
	log.Printf("Gin cold start")
	r := gin.Default()
	r.GET("/healthz", func(c *gin.Context) {
		c.JSON(200, "OK")
	})

	r.GET("/auth", OAuthAuthProvider)
	r.GET("/auth/:provider/callback", OAuthAuthProviderCallback)
	r.GET("/logout/:provider", OAuthLogoutProvider)
	r.GET("/auth/:provider", OAuthAuthProvider)

	ginLambda = ginadapter.New(r)
}

func Handler(ctx context.Context, req events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	// If no name is provided in the HTTP request body, throw an error
	return ginLambda.ProxyWithContext(ctx, req)
}

func main() {
	lambda.Start(Handler)
}

const script = `<!DOCTYPE html><html><head><script>
if (!window.opener) {
  window.opener = {
	postMessage: function(action, origin) {
	  console.log(action, origin);
	}
  }
}
(function(status, provider, result) {
  function receiveMessage(e) {
	console.log("Receive message:", e);
	// send message to main window
	window.opener.postMessage(
	  "authorization:" + provider + ":" + status + ":" + JSON.stringify(result),
	  "%s",
	);
  }
  window.addEventListener("message", receiveMessage, false);
  // Start handshake with parent
  console.log("Sending message:", provider)
  window.opener.postMessage(
	"authorizing:" + provider,
	"%s",
  );
})("%s", "%s", %s)
</script></head><body></body></html>`

var TargetOrigin = "*"

func OAuthAuth(c *gin.Context) {
	url := fmt.Sprintf("auth/%s", c.Param("provider"))
	http.Redirect(c.Writer, c.Request, url, http.StatusTemporaryRedirect)
}

func OAuthAuthProviderCallback(c *gin.Context) {
	var (
		status string
		result string
	)
	provider, errProvider := gothic.GetProviderName(c.Request)
	user, errAuth := gothic.CompleteUserAuth(c.Writer, c.Request)
	status = "error"
	if errProvider != nil {
		log.Printf("provider failed with '%s'\n", errProvider)
		result = fmt.Sprintf("%s", errProvider)
	} else if errAuth != nil {
		log.Printf("auth failed with '%s'\n", errAuth)
		result = fmt.Sprintf("%s", errAuth)
	} else {
		log.Printf("Logged in as %s user: %s (%s)\n", user.Provider, user.Email, user.AccessToken)
		status = "success"
		result = fmt.Sprintf(`{"token":"%s", "provider":"%s"}`, user.AccessToken, user.Provider)
	}
	c.Writer.Header().Set("Content-Type", "text/html; charset=utf-8")
	c.Writer.WriteHeader(http.StatusOK)
	c.Writer.Write([]byte(fmt.Sprintf(script, TargetOrigin, TargetOrigin, status, provider, result)))
}

func OAuthLogoutProvider(c *gin.Context) {

}

func OAuthAuthProvider(c *gin.Context) {
	gothic.BeginAuthHandler(c.Writer, c.Request)
}
