package main

import (
	"github.com/jwaldrip/odin/cli"
	"github.com/docker/docker/client"
	"github.com/docker/docker/api/types"
	"github.com/docker/docker/api/types/filters"
	"fmt"
	"strings"
	"os/user"
	"github.com/docker/libcompose/project"
	"github.com/docker/libcompose/utils"
	"github.com/docker/libcompose/yaml"
	"context"
)

var app = cli.New(readVersion(), "docdepot", func(c cli.Command) { c.Usage() })

func main() {
	app.DefineSubCommand("generate", "Generates a docker compose file for the specified docdepot containers",
		func(c cli.Command) {
			fmt.Println(generate(c.Args().Strings()))
		})

	rmSubCommand := app.DefineSubCommand("rm", "Removes all docdepot containers and networks",
		func(c cli.Command) {
			rm(c.Flag("force").Get().(bool))
		})

	rmSubCommand.DefineBoolFlag("force", false, "Force the removal of running containers")

	app.Start()
}

func generate(containers []string) (string) {
	images := []string{}
	imagesWithTags := map[string]string{}

	for _, imageWithTag := range containers {
		if strings.Contains(imageWithTag, ":") {
			imagesWithTagParts := strings.Split(imageWithTag, ":")
			imagesWithTags[imagesWithTagParts[0]] = imagesWithTagParts[1]
			images = append(images, imagesWithTagParts[0])
		} else {
			imagesWithTags[imageWithTag] = ""
			images = append(images, imageWithTag)
		}
	}

	user, prj := readProject()

	for image, _ := range imagesWithTags {
		if prj.ServiceConfigs.All()[image] == nil {
			panic(fmt.Sprintf("component %v not found in template", image))
		}
	}

	if len(imagesWithTags) > 0 {
		for _, sc := range prj.ServiceConfigs.All() {
			if sc.Labels["docdepot.hostnames"] != "" && !utils.Contains(sc.DependsOn, "nginx") {
				sc.DependsOn = append(sc.DependsOn, "nginx")
			}
		}

		for name, sc := range prj.ServiceConfigs.All() {
			for _, dep := range sc.DependsOn {
				if utils.Contains(images, name) && !utils.Contains(images, dep) {
					images = append(images, dep)
				}
			}
		}
	}

	nginxHosts := map[string]string{}

	for name, sc := range prj.ServiceConfigs.All() {
		if len(images) > 0 && !utils.Contains(images, name) {
			prj.ServiceConfigs.Remove(name)
			continue
		}

		if imagesWithTags[name] != "" {
			sc.Image += ":" + imagesWithTags[name]
			sc.Volumes = &yaml.Volumes{}
		}

		if sc.Labels == nil {
			sc.Labels = map[string]string{}
		}

		if sc.Labels["docdepot.glassfish"] == "true" {
			sc.Environment = append(sc.Environment, "DEBUG_GLASSFISH=true")
		}

		if sc.Labels["docdepot.tomcat"] == "true" {
			javaOptsIndex := -1

			for i, env := range sc.Environment {
				if strings.HasPrefix(env, "JAVA_OPTS=") {
					javaOptsIndex = i
				}
			}

			if javaOptsIndex == -1 {
				sc.Environment = append(sc.Environment, "JAVA_OPTS=-Xdebug -Xrunjdwp:transport=dt_socket,address=5005,server=y,suspend=n")
			} else {
				sc.Environment[javaOptsIndex] += " -Xdebug -Xrunjdwp:transport=dt_socket,address=5005,server=y,suspend=n"
			}

			sc.Environment = append(sc.Environment, "CATALINA_OPTS: -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=9000 -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false")
		}

		if sc.Labels["docdepot.glassfish"] == "true" || sc.Labels["docdepot.tomcat"] == "true" {
			sc.Environment = append(sc.Environment, "AWS_DYNAMODB_TABLE_PROPERTY=devConfigurationDynamoTableProperties")
			sc.Environment = append(sc.Environment, "AWS_REGION=ap-southeast-2")

			if sc.Volumes == nil {
				sc.Volumes = &yaml.Volumes{Volumes: []*yaml.Volume{}}
			}

			sc.Volumes.Volumes = append(sc.Volumes.Volumes, &yaml.Volume{Source: "~/.aws/credentials", Destination: "/root/.aws/credentials", AccessMode: "ro"})
			sc.Volumes.Volumes = append(sc.Volumes.Volumes, &yaml.Volume{Source: "~/.docdepot/tmp", Destination: "/usr/local/tomcat/tmp/"})
		}

		sc.Labels["docdepot"] = "true"

		nginxHostnames := strings.Split(sc.Labels["docdepot.hostnames"], ",")

		for _, nginxHostname := range nginxHostnames {
			if nginxHostname != "" {
				nginxHosts[nginxHostname] = sc.Networks.Networks[0].IPv4Address
			}
		}

		if sc.Volumes != nil {
			for _, volume := range sc.Volumes.Volumes {
				volume.Destination = strings.Replace(volume.Destination, "~", user.HomeDir, -1)
				volume.Source = strings.Replace(volume.Source, "~", user.HomeDir, -1)
			}
		}
	}

	if len(nginxHosts) > 0 {
		nginx, found := prj.ServiceConfigs.Get("nginx");
		if !found {
			panic("nginx container required but not found in template")
		}

		nginxConfig := "proxy_buffers 4 256k; proxy_buffer_size 128k;"

		for host, ip := range nginxHosts {
			nginx.Networks.Networks[0].Aliases = append(nginx.Networks.Networks[0].Aliases, host)
			nginxConfig += fmt.Sprintf("server { listen 80; server_name %v; location / { proxy_pass http://%v:8080; } } \n", host, ip)
		}

		nginx.Command = []string{"bash", "-c", "echo '" + nginxConfig + "' > /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"}
	}

	cfg, err := prj.Config()

	if err != nil {
		panic(err)
	}

	return cfg
}

func readProject() (*user.User, *project.Project) {
	user, err := user.Current()

	if err != nil {
		panic(err)
	}

	template, err := Asset("data/docdepot.yml")

	prj := project.NewProject(&project.Context{
		ComposeBytes: [][]byte{template},
		ProjectName: "docdepot",
	}, nil, nil)

	if err := prj.Parse(); err != nil {
		panic(fmt.Sprintf("Failed to parse template %v : %v", template, err))
	}

	return user, prj
}

func readVersion() string {
	version, err := Asset("data/version")

	if err != nil {
		panic(err)
	}

	return string(version)
}

func rm(force bool) {
	ctx := context.Background()

	cli, err := client.NewClientWithOpts(client.WithVersion("1.30"))

	if err != nil {
		panic(err)
	}

	containers, err := cli.ContainerList(ctx, types.ContainerListOptions{All: true, Filters: filters.NewArgs(filters.Arg("label", "docdepot"))})

	if err != nil {
		panic(err)
	}

	success := true

	for _, container := range containers {
		if !force && container.State == "running" {
			fmt.Println("Container " + container.Names[0] + " is still running, use --force to remove anyway")

			success = false
		} else {
			fmt.Println("Removing container " + container.Names[0])

			err = cli.ContainerRemove(ctx, container.ID, types.ContainerRemoveOptions{Force: true});
			if err != nil {
				panic(err)
			}
		}
	}

	if !success {
		return
	}

	// TODO should be changed to labels once libcompose supports v2.1
	networks, err := cli.NetworkList(ctx, types.NetworkListOptions{})

	for _, network := range networks {
		if strings.HasSuffix(network.Name, "_docdepot") {
			fmt.Println("Removing network " + network.Name)

			err = cli.NetworkRemove(ctx, network.ID)

			if err != nil {
				panic(err)
			}
		}
	}
}
