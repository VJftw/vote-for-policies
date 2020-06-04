package result

import (
	"fmt"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/dynamodb"
	"github.com/aws/aws-sdk-go/service/dynamodb/dynamodbattribute"
)

// DynamoDB represents the DynamoDB results storage
type DynamoDB struct {
	svc       *dynamodb.DynamoDB
	tableName *string
}

// NewDynamoDB returns a new DynamoDB results storage
func NewDynamoDB(
	sess *session.Session,
	tableName string,
	cfgs ...*aws.Config,
) *DynamoDB {
	svc := dynamodb.New(sess, cfgs...)
	return &DynamoDB{
		svc:       svc,
		tableName: aws.String(tableName),
	}
}

// Save implements Storage.Save
func (s *DynamoDB) Save(r *Result) error {
	av, err := dynamodbattribute.MarshalMap(r)
	if err != nil {
		return fmt.Errorf("could not marshal to dynamodb: %w", err)
	}

	input := &dynamodb.PutItemInput{
		Item:      av,
		TableName: s.tableName,
	}

	_, err = s.svc.PutItem(input)
	if err != nil {
		return fmt.Errorf("could not insert into dynamodb: %w", err)
	}

	return nil
}
