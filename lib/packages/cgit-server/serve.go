package main

import (
	"log"
	"net/http"
	"net/http/cgi"
	"os"
	"path/filepath"
)

func fileHandler(path string) func(http.ResponseWriter, *http.Request) {
	return func(w http.ResponseWriter, r *http.Request) {
		http.ServeFile(w, r, path)
	}
}

func main() {
	cgitDir := os.Getenv("CGIT_DIR")
	if cgitDir == "" {
		log.Fatalln("CGIT_DIR is missing")
	}

	port := os.Getenv("PORT")
	if port == "" {
		port = "80"
	}

	cgitFile := func(path string) string {
		return filepath.Join(cgitDir, path)
	}
	
	logo := os.Getenv("LOGO")
	var favicon string
	if logo == "" {
		logo = cgitFile("cgit.png")
		favicon = cgitFile("favicon.ico")
	} else {
		favicon = logo
	}

	cgitHandler := cgi.Handler{
		Path: cgitFile("cgit.cgi"),
		InheritEnv: []string{"CGIT_CONFIG"},
	}

	mux := http.NewServeMux()
	mux.Handle("/", &cgitHandler)
	mux.HandleFunc("/cgit.css", fileHandler(cgitFile("cgit.css")))
	mux.HandleFunc("/robots.txt", fileHandler(cgitFile("robots.txt")))
	mux.HandleFunc("/logo.png", fileHandler(logo))
	mux.HandleFunc("/favicon.ico", fileHandler(favicon))

	err := http.ListenAndServe("localhost:"+port, mux)
	if err != nil {
		log.Fatal(err)
	}
}
