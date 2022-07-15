#!/bin/bash
dotnet-install() {
sudo rpm -Uvh https://packages.microsoft.com/config/centos/7/packages-microsoft-prod.rpm
sudo yum install -y dotnet-sdk-6.0
sudo yum install -y aspnetcore-runtime-6.0
main
}

create-app() {
    if [[ -d ~/dotnet-docker ]]
    then
    echo "A mappa már létezik"
    else
    mkdir ~/dotnet-docker
    fi
    cp Dockerfile ~/dotnet-docker
    cd ~/dotnet-docker
    dotnet new console -o App -n DotNet.Docker
    cp Dockerfile App
    rm Dockerfile
    cd App
    dotnet run
    rm Program.cs
    touch Program.cs
    echo "var counter = 0;
var max = args.Length != 0 ? Convert.ToInt32(args[0]) : -1;
while (max == -1 || counter < max)
{
    Console.WriteLine($\"Counter: {++counter}\");
    await Task.Delay(TimeSpan.FromMilliseconds(1_000));
}" >> Program.cs
    dotnet publish -c Release
    main
}

create-container() {
    cd ~/dotnet-docker/App
    docker build -t counter-image -f Dockerfile .
    docker create --name core-counter counter-image
    docker start core-counter
    docker attach --sig-proxy=false core-counter
    main
}

main() {
    printf "1. .NET install\n2. .NET app készítése\n3. konténer készítése\n"
    read -p "Válasszon:" func
    if [[ $func == "1" ]]
    then
    dotnet-install
    elif [[ $func == "2" ]]
    then
    create-app
    elif [[ $func == "3" ]]
    then
    create-container
    fi
}
main