Class {
	#name : #IceGitCliRepositoryExamples,
	#superclass : #Object,
	#category : #'GToolkit4Git-Examples'
}

{ #category : #accessing }
IceGitCliRepositoryExamples >> commitChanges [
	<gtExample>
	<noTest>
	| commit diff |
	commit := self commitInformation ancestors first.
	diff := IceDiff from: commit to: commit parent.
	self assert: diff isEmpty not.
	^ diff
]

{ #category : #accessing }
IceGitCliRepositoryExamples >> commitFilesystem [
	<gtExample>
	<noTest>
	| fs |
	fs := self commitInformation fileSystem fileSystem.
	self assert: (fs referenceTo: '.project') exists.
	self assert: (fs referenceTo: 'src/GToolkit4Git/GtGitExamples.class.st') exists.
	^ fs
]

{ #category : #accessing }
IceGitCliRepositoryExamples >> commitInformation [
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
IceGitCliRepositoryExamples >> createRepository [
	<gtExample>
	<noTest>
	| iceRepository repositoryFolder |
	(IceRepository registry
		contains: [ :rep | rep name = self exampleRepositoryName ]) ifTrue: [ ^ self ].
	repositoryFolder := FileReference
			newTempFilePrefix: self exampleRepositoryName
			suffix: 'dir'.
	iceRepository := GtIceRepositoryCreator
			fromUrl: self exampleRepositoryUrl
			to: repositoryFolder.
	iceRepository name: self exampleRepositoryName.
	IceRepository registerRepository: iceRepository.
	self assert: iceRepository branchName = 'main'.
	^ iceRepository
]

{ #category : #accessing }
IceGitCliRepositoryExamples >> exampleRepositoryName [
	^ 'gt4git'
]

{ #category : #accessing }
IceGitCliRepositoryExamples >> exampleRepositoryUrl [
	^ 'https://github.com/feenkcom/gt4git.git'
]

{ #category : #accessing }
IceGitCliRepositoryExamples >> gt4gitRepository [
	<gtExample>
	<noTest>
	self createRepository.
	^ IceGitCliRepository
		fromLibGitRepository: (IceRepository registry
				detect: [ :each | each name = self exampleRepositoryName ])
]

{ #category : #accessing }
IceGitCliRepositoryExamples >> repositoryPackages [
	<gtExample>
	<noTest>
	| repo packages |
	repo := self gt4gitRepository.
	packages := repo packages.
	self assert: (packages contains: [ :pkg | pkg name = 'GToolkit4Git' ]).
	^ packages
]

{ #category : #accessing }
IceGitCliRepositoryExamples >> repositoryTagInformation [
	<gtExample>
	<noTest>
	| tag |
	tag := self repositoryTags detect: [:each | each name = 'v0.8.99'].
	self assert: (tag commit id beginsWith: '2ff1365').
	^ tag
]

{ #category : #accessing }
IceGitCliRepositoryExamples >> repositoryTags [
	<gtExample>
	<noTest>
	| repo tags |
	repo := self gt4gitRepository.
	tags := repo tags.
	self assert: (tags contains: [ :tag | tag name = 'v0.8.99' ]).
	^ tags
]

{ #category : #accessing }
IceGitCliRepositoryExamples >> revListForBranch [
	<gtExample>
	<noTest>
	| repo branch |
	repo := self gt4gitRepository.
	branch := repo branchNamed: 'main'.
	^ repo revListForBranch: branch
]
