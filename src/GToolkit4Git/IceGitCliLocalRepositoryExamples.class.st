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
IceGitCliLocalRepositoryExamples >> cloneRepositoryAIntoRepositoryB [
	<gtExample>
	
	| repositoryB repositoryA repositoryAUrl |
	
	self repositoryBLocation exists ifTrue: [ self deleteRepositoryB ].

	repositoryA := self firstCommitInRepositoryA.
	repositoryAUrl := repositoryA location resolve asUrl.
	
	repositoryB := GtIceRepositoryCreator new
		location: self repositoryBLocation;
		url: repositoryAUrl asString;
		cloneRepository.

	self assert: (repositoryB location / 'number.txt') exists.

	^ repositoryB
]

{ #category : #accessing }
IceGitCliLocalRepositoryExamples >> createBranchXInRepositoryA [
	<gtExample>
	<noTest>

	| repositoryA branchX |

	repositoryA := self repositoryA.

	branchX := repositoryA 
		branchNamed: 'branch-x'
		ifAbsent: [ repositoryA createBranch: 'branch-x' ].
	
	branchX switch.

	self assert: repositoryA head name = 'branch-x'.
	
	^ repositoryA
]

{ #category : #accessing }
IceGitCliLocalRepositoryExamples >> deleteRepositoryA [
	self repositoryALocation deleteAll
]

{ #category : #accessing }
IceGitCliLocalRepositoryExamples >> deleteRepositoryB [
	self repositoryBLocation deleteAll
]

{ #category : #accessing }
IceGitCliLocalRepositoryExamples >> firstCommitInRepositoryA [
	<gtExample>
	<noTest>

	| repositoryA numberFile workingCopy |

	repositoryA := self repositoryA.

	numberFile := repositoryA location / 'number.txt'.
	(numberFile exists and: [ numberFile contents trimBoth = '1. first' ])
		ifTrue: [ ^ repositoryA ].
	numberFile writeStreamDo: [ :out | 
		out << '1. first' << OSPlatform current lineEnding ].

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
IceGitCliLocalRepositoryExamples >> initRepositoryA [
	<gtExample>
	<noTest>

	| repositoryA |

	self repositoryALocation exists ifTrue: [ self deleteRepositoryA ].

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

	| repositoryB |

	repositoryB := self secondCommitInRepositoryB.

	self assert: repositoryB outgoingCommits isEmpty not.
	
	self createBranchXInRepositoryA. "git won't push into local remote when branch is the same"

	repositoryB push.
	
	self assert: repositoryB outgoingCommits isEmpty.

	^ repositoryB
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

{ #category : #accessing }
IceGitCliLocalRepositoryExamples >> repositoryB [
	<gtExample>
	<noTest>
	
	^ self repositoryBLocation exists
		ifTrue: [ 
			(IceGitCliRepository on: self repositoryBLocation) 
				name: self repositoryBName; 
				yourself ]
		ifFalse: [ self cloneRepositoryAIntoRepositoryB ]
]

{ #category : #accessing }
IceGitCliLocalRepositoryExamples >> repositoryBLocation [
	<gtExample>
	<noTest>

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

	| repositoryB numberFile workingCopy |

	repositoryB := self repositoryB.

	numberFile := repositoryB location / 'number.txt'.
	(numberFile exists and: [ numberFile contents trimBoth = '2. second' ])
		ifTrue: [ ^ repositoryB ].
	numberFile writeStreamDo: [ :out |
		out truncate.
		out << '2. second' << OSPlatform current lineEnding ].

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

{ #category : #accessing }
IceGitCliLocalRepositoryExamples >> switchToMainInRepositoryA [
	<gtExample>
	<noTest>

	| repositoryA |

	repositoryA := self firstCommitInRepositoryA.

	(repositoryA branchNamed: 'main') switch.

	self assert: repositoryA head name = 'main'.
	
	^ repositoryA
]
