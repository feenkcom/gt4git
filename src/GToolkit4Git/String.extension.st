Extension { #name : #String }

{ #category : #'*GToolkit4Git' }
String >> gtCloneGithubRepository [

	| url owner project |
	url := self copyReplaceAll: 'git@github.com:' with: ''.
	url := url copyReplaceAll: '.git' with: ''.
	owner := (url findTokens: '/') first.
	project := (url findTokens: '/') last.

	^ GtGitRepository fromIcebergRepository: (IceRepository repositoryClass creatorClass new
			   remote: (IceGitRemote url: self);
			   location:
				   IceLibgitRepository repositoriesLocation / owner / project;
			   createRepository)
]
