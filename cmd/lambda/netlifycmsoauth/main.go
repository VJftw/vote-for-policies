package main

import (
	"context"
	"log"

	"github.com/VJftw/vote-for-policies/pkg/handlers"
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	ginadapter "github.com/awslabs/aws-lambda-go-api-proxy/gin"
	"github.com/gin-gonic/gin"
)

var ginLambda *ginadapter.GinLambda

func init() {
	// stdout and stderr are sent to AWS CloudWatch Logs
	log.Printf("Gin cold start")
	r := gin.Default()
	r.GET("/healthz", func(c *gin.Context) {
		c.JSON(200, "OK")
	})

	r.GET("/auth", handlers.OAuthAuthProvider)
	r.GET("/auth/:provider/callback", handlers.OAuthAuthProviderCallback)
	r.GET("/logout/:provider", handlers.OAuthLogoutProvider)
	r.GET("/auth/:provider", handlers.OAuthAuthProvider)

	ginLambda = ginadapter.New(r)
}

func Handler(ctx context.Context, req events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	// If no name is provided in the HTTP request body, throw an error
	return ginLambda.ProxyWithContext(ctx, req)
}

func main() {
	lambda.Start(Handler)
}
