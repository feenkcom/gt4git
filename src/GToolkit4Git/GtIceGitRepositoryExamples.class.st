Class {
	#name : #GtIceGitRepositoryExamples,
	#superclass : #Object,
	#category : #'GToolkit4Git-Examples'
}

{ #category : #accessing }
GtIceGitRepositoryExamples >> commitChanges [
	<gtExample>
	<noTest>
	| commit diff |
	commit := self commitInformation ancestors first.
	diff := IceDiff from: commit to: commit parent.
	self assert: diff isEmpty not.
	^ diff
]

{ #category : #accessing }
GtIceGitRepositoryExamples >> commitFilesystem [
	<gtExample>
	<noTest>
	| fs |
	fs := self commitInformation fileSystem fileSystem.
	self assert: (fs referenceTo: '.project') exists.
	self assert: (fs referenceTo: 'src/GToolkit4Git/GtGitExamples.class.st') exists.
	^ fs
]

{ #category : #accessing }
GtIceGitRepositoryExamples >> commitInformation [
	<gtExample>
	<noTest>
	| commit |
	commit := self repositoryTagInformation commit.
	self assert: (commit id beginsWith: '2ff1365').
	self assert: (commit ancestors size = 1).
	self assert: (commit ancestors first id beginsWith: 'd323299').
	self assert: (commit author = 'Jenkins').
	^ commit
]

{ #category : #accessing }
GtIceGitRepositoryExamples >> createRepository [
	<gtExample>
	<noTest>
	| iceRepository repositoryFolder repositoryName |
	"(IceRepository registry
		contains: [ :rep | 
			repositoryName := self exampleRepositoryName.
			rep name = repositoryName ]) ifTrue: [ ^ self ]."
	repositoryFolder := FileReference
			newTempFilePrefix: self exampleRepositoryName
			suffix: 'dir'.

	iceRepository := GtIceRepositoryCreator
			fromUrl: 'https://github.com/feenkcom/gt4git.git'
			to: repositoryFolder.


	self assert: (self mainBranchNames includes: iceRepository branchName).

	iceRepository workingCopy commitWithMessage: 'Add properties and project files'.	"Ideally do not register the repository with Iceberg.
	Registered for now to make ot easy to debug."
	IceRepository registerRepository: iceRepository.
	self repositories at: repositoryName put: iceRepository.	"Ensure the repo was creates successfully"
	self assert: iceRepository isMissing not description: 'Repository is present'.
	self
		assert: iceRepository isModified not
		description: 'Repository is not modified'.
	self assert: iceRepository branch commits size equals: 1.

	^ iceRepository
]

{ #category : #accessing }
GtIceGitRepositoryExamples >> exampleRepositoryName [
	^ 'gt4git'
]

{ #category : #accessing }
GtIceGitRepositoryExamples >> gt4gitRepository [
	<gtExample>
	<noTest>
	^ GtIceGitRepository
		fromLibGitRepository: (IceRepository registry detect: [ :each | each name = 'gt4git' ])
]

{ #category : #accessing }
GtIceGitRepositoryExamples >> repositoryPackages [
	<gtExample>
	<noTest>
	| repo packages |
	repo := self gt4gitRepository.
	packages := repo packages.
	self assert: (packages contains: [ :pkg | pkg name = 'GToolkit4Git' ]).
	^ packages
]

{ #category : #accessing }
GtIceGitRepositoryExamples >> repositoryTagInformation [
	<gtExample>
	<noTest>
	| tag |
	tag := self repositoryTags detect: [:each | each name = 'v0.8.99'].
	self assert: (tag commit id beginsWith: '2ff1365').
	^ tag
]

{ #category : #accessing }
GtIceGitRepositoryExamples >> repositoryTags [
	<gtExample>
	<noTest>
	| repo tags |
	repo := self gt4gitRepository.
	tags := repo tags.
	self assert: (tags contains: [ :tag | tag name = 'v0.8.99' ]).
	^ tags
]
