
job "filebrowser" {
  datacenters = ["homelab"]
  priority    = 50
  type        = "service"
  meta {
    forcedeploy = "0"
  }
  constraint {
    attribute = "${attr.cpu.arch}"
    value     = "amd64"
  }

  group "filebrowser" {
    network {
      mode = "host"
      port "http" {
        to = 80
      }
    }
    volume "filebrowser-data" {
      type      = "csi"
      source    = "filebrowser-data"
      access_mode = "single-node-writer"
      attachment_mode = "file-system"
    }
    volume "root" {
      type      = "csi"
      source    = "root"
      access_mode = "single-node-writer"
      attachment_mode = "file-system"
    }
    vault {
    }
    task "filebrowser" {
      driver = "docker"
      service {
        name = "filebrowser"
        port = "http"
        tags = [
          "homer.enable=true",
          "homer.name=filebrowser",
          "homer.service=Application",
          "homer.url=http://file.ducamps.eu",
          "homer.logo=http://file.ducamps.eu/public/static/loginIcon", 
          "homer.target=_blank",
          "traefik.enable=true",
          "traefik.http.routers.${NOMAD_JOB_NAME}.rule=Host(`file.ducamps.eu`)",
          "traefik.http.routers.${NOMAD_JOB_NAME}.tls.domains[0].sans=file.ducamps.eu",
          "traefik.http.routers.${NOMAD_JOB_NAME}.tls.certresolver=myresolver",
          "traefik.http.routers.${NOMAD_JOB_NAME}.entrypoints=web,websecure",


        ]
      }
      config {
        image = "gtstef/filebrowser:1.1.1-stable"
        ports = ["http"]
        volumes = [
          "local/config.yaml:/home/filebrowser/config.yaml",
        ]
        
      }
      volume_mount {
        volume      = "filebrowser-data"
        destination = "/home/filebrowser/data"
      }
      volume_mount {
        volume      = "root"
        destination = "/srv"
      }

      template {
        destination = "local/config.yaml"
        data = <<EOF
server:                                                                                               
  database: "data/database.db"                                                                        
  port: 80                                                                                            
  baseURL:  "/"                                                                                       
  logging:                                                                                            
    - levels: "info|warning|error"                                                                    
  sources:                                                                                            
    - path: "/srv"                                                                                    
auth:
  methods:
    password:
      enabled: false
    oidc:
      enabled: true
      clientId: 'filebrowser'
      clientSecret: {{ with secret "secrets/data/authelia/filebrowser"}} {{ .Data.data.password }} {{end}}
      issuerUrl: 'https://auth.ducamps.eu'
      scopes: 'email openid profile groups'
      userIdentifier: 'preferred_username'
      disableVerifyTLS: false
      logoutRedirectUrl: ''
      createUser: true
      adminGroup: 'FilebrowserAdmins'
      groupsClaim: 'groups'
userDefaults:                                                                                         
  editorQuickSave: false                  # show quick save button in editor                          
  hideSidebarFileActions: false           # hide the file actions in the sidebar                      
  disableQuickToggles: false              # disable the quick toggles in the sidebar                  
  disableSearchOptions: false             # disable the search options in the search bar              
  stickySidebar: true                     # keep sidebar open when navigating                         
  darkMode: true                          # should dark mode be enabled                               
  viewMode: "list"                      # view mode to use: eg. normal, list, grid, or compact      
  singleClick: false                      # open directory on single click, also enables middle click to open in new tab                                                                                    
  showHidden: false                       # show hidden files in the UI. On windows this includes files starting with a dot and windows hidden files                                                        
  dateFormat: false                       # when false, the date is relative, when true, the date is an exact timestamp                                                                                     
  gallerySize: 3                          # 0-9 - the size of the gallery thumbnails                  
  themeColor: "var(--blue)"               # theme color to use: eg. #ff0000, or var(--red), var(--purple), etc                                                                                              
  quickDownload: false                    # show icon to download in one click                        
  disablePreviewExt: ""                   # space separated list of file extensions to disable preview for                                                                                                 
  disableViewingExt: ""                   # space separated list of file extensions to disable viewing for                                                                                                  
  lockPassword: false                     # disable the user from changing their password             
  disableSettings: false                  # disable the user from viewing the settings page           
  preview:                                                                                            
    disableHideSidebar: true             # disable the hide sidebar preview for previews and editors  
    highQuality: true                    # generate high quality thumbnail preview images
    image: true                          # show thumbnail preview image for image files
    video: true                          # show thumbnail preview image for video files
    motionVideoPreview: true             # show multiple frames for videos in thumbnail preview when h
overing:
    office: true                         # show thumbnail preview image for office files
    popup: true                          # show larger popup preview when hovering over thumbnail
    autoplayMedia: true                  # autoplay media files in preview
    defaultMediaPlayer: true             # disable html5 media player and use the default media player
    folder: true                         # show thumbnail preview image for folder files
permissions:
    api: false                            # allow api access
    admin: false                          # allow admin access
    modify: false                         # allow modifying files
    share: true                          # allow sharing files
    realtime: false                       # allow realtime updates
    delete: false                         # allow deleting files
    create: true                         # allow creating or uploading files
    download: true                        # allow downloading files
disableUpdateNotifications: false       # disable update notifications banner for admin users
deleteWithoutConfirming: false          # delete files without confirmation
disableOnlyOfficeExt: ".md .txt .pdf"   # list of file extensions to disable onlyoffice editor for
showSelectMultiple: false               # show select multiple files on desktop
defaultLandingPage: ""                  # default landing page to use if no redirect is specified: e
        EOF 
      }
      env {
        APPLICATION_URL = ""
        FILEBROWSER_CONFIG= "/home/filebrowser/config.yaml"
      }

      resources {
        cpu    = 100
        memory = 300
        memory_max = 2000
      }
    }

  }
}
