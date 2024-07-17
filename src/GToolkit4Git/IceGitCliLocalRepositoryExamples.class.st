Class {
	#name : #IceGitCliLocalRepositoryExamples,
	#superclass : #Object,
	#instVars : [
		'repositoryA',
		'repositoryB'
	],
	#category : #'GToolkit4Git-Examples'
}

{ #category : #accessing }
IceGitCliLocalRepositoryExamples >> baseDirectory [
	^ (FileLocator temp / self class name) ensureCreateDirectory
]

{ #category : #accessing }
IceGitCliLocalRepositoryExamples >> cloneRepositoryAIntoRepositoryB [
	<gtExample>
	<noTest>
	
	| repositoryAUrl numberFile |
	
	self repositoryBLocation exists 
		ifTrue: [ self repositoryBLocation deleteAll ].

	repositoryA := self firstCommitInRepositoryA.

	repositoryAUrl := repositoryA location resolve asUrl.
	
	repositoryB := GtIceRepositoryCreator new
		location: self repositoryBLocation;
		url: repositoryAUrl asString;
		cloneRepository.

	repositoryB name: self repositoryBName.

	numberFile := repositoryB location / 'number.txt'.
	
	self assert: numberFile exists.
	self assert: numberFile contents trimBoth = '1. first'.
	self assert: repositoryA head commits first comment trimBoth = 'First commit'.

	^ repositoryB
]

{ #category : #accessing }
IceGitCliLocalRepositoryExamples >> firstCommitInRepositoryA [
	<gtExample>
	<noTest>

	| numberFile workingCopy |

	repositoryA := self initRepositoryA.

	numberFile := repositoryA location / 'number.txt'.

	numberFile writeStreamDo: [ :out | 
		(ZnNewLineWriterStream on: out) << '1. first'; cr ].

	repositoryA addFileToIndex: numberFile basename.

	workingCopy := repositoryA workingCopy.

	workingCopy
		commitChanges: workingCopy diffToReferenceCommit 
		withMessage: 'First commit' 
		force: true.

	self assert: repositoryA head name = 'main'.
	self assert: repositoryA localBranches first name = 'main'.
	self assert: repositoryA head commits first comment trimBoth = 'First commit'.

	^ repositoryA
]

{ #category : #accessing }
IceGitCliLocalRepositoryExamples >> gitVersion [
	<gtExample>
	<noTest>
	
	^ IceGitCliPlatform current gitVersion
]

{ #category : #accessing }
IceGitCliLocalRepositoryExamples >> initRepositoryA [
	<gtExample>
	<noTest>

	self repositoryALocation exists 
		ifTrue: [ self repositoryALocation deleteAll ].

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
IceGitCliLocalRepositoryExamples >> pushRepositoryBToRepositoryA [
	<gtExample>
	<noTest>

	| numberFile |

	repositoryB := self secondCommitInRepositoryB.

	self assert: repositoryB outgoingCommits isEmpty not.

	"git won't push into local remote when branch is the same"

	repositoryA createBranch: 'branch-temporary'.

	repositoryB push.

	self assert: repositoryB outgoingCommits isEmpty.

	repositoryA switchToBranchNamed: 'main'.

	numberFile := repositoryA location / 'number.txt'.

	self assert: numberFile contents trimBoth = '2. second'.
	self assert: repositoryA branch commit comment trimBoth = 'Second commit'.

	^ self
]

{ #category : #accessing }
IceGitCliLocalRepositoryExamples >> repositoryALocation [
	^ self baseDirectory / self repositoryAName
]

{ #category : #accessing }
IceGitCliLocalRepositoryExamples >> repositoryAName [
	^ 'RepositoryA'
]

{ #category : #accessing }
IceGitCliLocalRepositoryExamples >> repositoryBLocation [
	^ self baseDirectory / self repositoryBName
]

{ #category : #accessing }
IceGitCliLocalRepositoryExamples >> repositoryBName [
	^ 'RepositoryB'
]

{ #category : #accessing }
IceGitCliLocalRepositoryExamples >> secondCommitInRepositoryB [
	<gtExample>
	<noTest>

	| numberFile workingCopy |

	repositoryB := self cloneRepositoryAIntoRepositoryB.

	numberFile := repositoryB location / 'number.txt'.

	numberFile writeStreamDo: [ :out |
		out truncate.
		(ZnNewLineWriterStream on: out) << '2. second'; cr ].

	repositoryB addFileToIndex: numberFile basename.

	workingCopy := repositoryB workingCopy.

	workingCopy
		commitChanges: workingCopy diffToReferenceCommit 
		withMessage: 'Second commit' 
		force: true.

	self assert: repositoryB head name = 'main'.
	self assert: repositoryB localBranches first name = 'main'.
	self assert: repositoryB head commits first comment trimBoth = 'Second commit'.

	^ repositoryB
]
