package result

import (
	"fmt"
	"io"
	"path/filepath"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/s3"
)

type S3 struct {
	svc        *s3.S3
	bucketName *string
	keyPrefix  string
}

func NewS3(
	sess *session.Session,
	bucketName string,
	keyPrefix string,
	cfgs ...*aws.Config,
) *S3 {
	svc := s3.New(sess, cfgs...)
	return &S3{
		svc:        svc,
		bucketName: aws.String(bucketName),
		keyPrefix:  keyPrefix,
	}
}

func (s *S3) Save(key string, body io.ReadSeeker) (string, error) {
	key = filepath.Join(s.keyPrefix, key)
	_, err := s.svc.PutObject(&s3.PutObjectInput{
		Body:         body,
		Bucket:       s.bucketName,
		Key:          aws.String(key),
		ContentType:  aws.String("text/html"),
		CacheControl: aws.String("max-age=120"),
	})

	if err != nil {
		return "", fmt.Errorf("could not upload to s3: %w", err)
	}

	return key, nil
}
