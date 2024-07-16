Class {
	#name : #IceGitCliLocalRepositoryExamples,
	#superclass : #Object,
	#category : #'GToolkit4Git-Examples'
}

{ #category : #accessing }
IceGitCliLocalRepositoryExamples >> baseDirectory [
	<gtExample>
	<noTest>

	^ (FileLocator temp / self class name) ensureCreateDirectory
]

{ #category : #accessing }
IceGitCliLocalRepositoryExamples >> deleteRepositoryA [
	self repositoryALocation deleteAll
]

{ #category : #accessing }
IceGitCliLocalRepositoryExamples >> firstCommitInRepositoryA [
	<gtExample>
	<noTest>

	| repositoryA numberFile|

	repositoryA := self repositoryA.

	numberFile := repositoryA location / 'number.txt'.
	numberFile writeStreamDo: [ :out | 
		out << '1. first' << OSPlatform current lineEnding ].

	repositoryA addFileToIndex: numberFile basename.

	[ repositoryA commitWithMessage: 'First commit' ]
		on: IceNothingToCommit
		do: [ ^ repositoryA ].

	self assert: repositoryA head name = 'main'.
	self assert: repositoryA localBranches first name = 'main'.
	self assert: repositoryA head commits first message = 'First commit'.
	
	^ repositoryA
]

{ #category : #accessing }
IceGitCliLocalRepositoryExamples >> initRepositoryA [
	<gtExample>
	<noTest>

	| repositoryA |

	self deleteRepositoryA.

	repositoryA := GtIceRepositoryCreator new
		location: self repositoryALocation;
		createNewRepositoryNamed: self repositoryAName.

	self assert: repositoryA isValid.
	self assert: repositoryA location = self repositoryALocation.
	self assert: repositoryA head commits isEmpty.
	self assert: repositoryA localBranches isEmpty.
	self assert: repositoryA remoteTrackedBranches isEmpty.

	^ repositoryA
]

{ #category : #accessing }
IceGitCliLocalRepositoryExamples >> repositoryA [
	<gtExample>
	<noTest>
	
	^ self repositoryALocation exists
		ifTrue: [ 
			(IceGitCliRepository on: self repositoryALocation) 
				name: self repositoryAName; 
				yourself ]
		ifFalse: [ self initRepositoryA ]
]

{ #category : #accessing }
IceGitCliLocalRepositoryExamples >> repositoryALocation [
	<gtExample>
	<noTest>

	^ self baseDirectory / self repositoryAName
]

{ #category : #accessing }
IceGitCliLocalRepositoryExamples >> repositoryAName [
	^ 'RepositoryA'
]
