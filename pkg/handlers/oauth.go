package handlers

import (
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/ssm"
	"github.com/gin-gonic/gin"
	"github.com/markbates/goth"
	"github.com/markbates/goth/gothic"
	"github.com/markbates/goth/providers/github"
)

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
	// send message to main window with da app
	window.opener.postMessage(
	  "authorization:" + provider + ":" + status + ":" + result,
	  e.origin
	);
  }
  window.addEventListener("message", receiveMessage, false);
  // Start handshake with parent
  console.log("Sending message:", provider)
  window.opener.postMessage(
	"authorizing:" + provider,
	"*"
  );
})("%s", "%s", %s)
</script></head><body></body></html>`

func init() {
	sess := session.Must(session.NewSession())
	ssmSvc := ssm.New(sess)

	paramRes, err := ssmSvc.GetParameter(&ssm.GetParameterInput{
		Name:           aws.String("/vfp-vjpatel-me/github-secret"),
		WithDecryption: aws.Bool(true),
	})
	if err != nil {
		panic(err)
	}

	githubSecret := aws.StringValue(paramRes.Parameter.Value)

	host := os.Getenv("HOST")
	goth.UseProviders(
		github.New(
			os.Getenv("GITHUB_ID"), githubSecret,
			fmt.Sprintf("https://%s/auth/github/callback", host),
		),
	)
}

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
	c.Writer.Write([]byte(fmt.Sprintf(script, status, provider, result)))
}

func OAuthLogoutProvider(c *gin.Context) {

}

func OAuthAuthProvider(c *gin.Context) {
	gothic.BeginAuthHandler(c.Writer, c.Request)
}
