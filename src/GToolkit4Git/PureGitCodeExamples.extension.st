Extension { #name : #PureGitCodeExamples }

{ #category : #'*GToolkit4Git' }
PureGitCodeExamples >> exampleGToolkit4GitPackage [
	<gtExample>
	<noTest>

	| repository package |

	repository := self exampleGt4Git.

	package := repository packages detect: [ :each | each name = 'GToolkit4Git' ].

	self assert: package isLoaded.

	^ package
]

{ #category : #'*GToolkit4Git' }
PureGitCodeExamples >> exampleGToolkit4GitPackageSnapshot [
	<gtExample>
	<noTest>

	| package snapshot |

	package := self exampleGToolkit4GitPackage.

	snapshot := package reader snapshot.

	self assert: snapshot notNil.
	
	^ snapshot
]

{ #category : #'*GToolkit4Git' }
PureGitCodeExamples >> exampleGt4Git [
	<gtExample>
	<noTest>

	| repository |

	repository := PureGitCodeRepository on: (IceRepository repositoryNamed: 'gt4git') location.

	self assert: repository exists.

	^ repository
]

{ #category : #'*GToolkit4Git' }
PureGitCodeExamples >> exampleMethodVersions [
	<gtExample>
	<noTest>

	| methodVersions |

	methodVersions := PureGitMethodVersions with: PureGitRepository >> #hasHead.

	self assert: methodVersions versions size >= 3.

	^ methodVersions
]
