package main

import (
	"context"
	"log"
	"os"

	"github.com/VJftw/vote-for-policies/pkg/voteforpolicies/handler"
	"github.com/VJftw/vote-for-policies/pkg/voteforpolicies/result"
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws/session"
	ginadapter "github.com/awslabs/aws-lambda-go-api-proxy/gin"
	"github.com/gin-gonic/gin"
)

var (
	r         *gin.Engine
	ginLambda *ginadapter.GinLambda
)

func init() {
	// stdout and stderr are sent to AWS CloudWatch Logs
	r = gin.Default()

	r.GET("/healthz", func(c *gin.Context) {
		c.JSON(200, "OK")
	})

	awsSession := session.Must(session.NewSession())
	// dynamodbConfig := &aws.Config{Endpoint: aws.String("https://test.us-west-2.amazonaws.com")}
	resultStorage := result.NewDynamoDB(awsSession, os.Getenv("DYNAMODB_TABLE"))
	renderer, err := result.NewRenderer()
	if err != nil {
		log.Fatal(err)
	}
	s3Origin := result.NewS3(awsSession, os.Getenv("RESULTS_BUCKET"), os.Getenv("RESULTS_BUCKET_KEY_PREFIX"))
	h := handler.New(resultStorage, renderer, s3Origin, os.Getenv("ORIGIN_ADDRESS"))

	r.POST("/", h.PostResults)
}

func main() {

	if len(os.Getenv("LAMBDA")) > 0 {
		ginLambda = ginadapter.New(r)
		lambda.Start(func(ctx context.Context, req events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
			return ginLambda.ProxyWithContext(ctx, req)
		})
	} else {
		if err := r.Run(); err != nil {
			log.Fatal(err)
		}
	}
}
