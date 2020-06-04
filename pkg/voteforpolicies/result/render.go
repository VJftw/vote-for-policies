package result

import (
	"bytes"
	"fmt"
	"html/template"
	"io/ioutil"
	"net/http"
	"os"

	// static files
	_ "github.com/VJftw/vote-for-policies/pkg/voteforpolicies/result/statik"
	"github.com/rakyll/statik/fs"
)

type Renderer struct {
	baseTemplate *template.Template

	resultTemplate *template.Template
}

func NewRenderer() (*Renderer, error) {
	statikFS, err := fs.New()
	if err != nil {
		return nil, fmt.Errorf("could not start statikFS: %w", err)
	}

	fs.Walk(statikFS, "/", func(path string, f os.FileInfo, err error) error {
		if !f.IsDir() {
			fmt.Println(f.Name())
		}
		return nil
	})

	baseTmpl, err := getFileTemplate(statikFS, "/base.html")
	if err != nil {
		return nil, err
	}

	resultContents, err := getFileContents(statikFS, "/result.html")
	if err != nil {
		return nil, err
	}

	resultTmpl, err := baseTmpl.Parse(resultContents)
	if err != nil {
		return nil, err
	}

	// baseReader, err := statikFS.Open("base.html")
	// if err != nil {
	// 	return nil, fmt.Errorf("could not open base file: %w", err)
	// }
	// defer baseReader.Close()
	// baseNode, err := html.Parse(baseReader)
	// if err != nil {
	// 	return fmt.Errorf("could not parse base html: %w", err)
	// }

	// resultReader, err := statikFS.Open("result.html")
	// if err != nil {
	// 	return nil, fmt.Errorf("could not open result file: %w", err)
	// }
	// defer resultReader.Close()
	// resultNode, err := html.Parse(resultReader)
	// if err != nil {
	// 	return fmt.Errorf("could not parse result html: %w", err)
	// }

	return &Renderer{
		// baseTemplate: baseTemplate,
		resultTemplate: resultTmpl,
	}, nil
}

func getFileContents(statikFS http.FileSystem, filename string) (string, error) {
	r, err := statikFS.Open(filename)
	if err != nil {
		return "", fmt.Errorf("could not open template: %w", err)
	}
	defer r.Close()

	contents, err := ioutil.ReadAll(r)
	if err != nil {
		return "", fmt.Errorf("could not read template: %w", err)
	}

	return string(contents), nil
}

func getFileTemplate(statikFS http.FileSystem, filename string) (*template.Template, error) {
	contents, err := getFileContents(statikFS, filename)
	if err != nil {
		return nil, err
	}
	tmpl, err := template.New(filename).Parse(string(contents))
	if err != nil {
		return nil, fmt.Errorf("could not parse template: %w", err)
	}

	return tmpl, nil
}

func (r *Renderer) RenderResult(result *Result) (string, error) {
	buf := &bytes.Buffer{}
	if err := r.resultTemplate.Execute(buf, result); err != nil {
		return "", err
	}
	return string(buf.Bytes()), nil
}

func RenderTotal() {

}