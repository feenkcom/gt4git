Class {
	#name : 'GtGitRepositories',
	#superclass : 'Object',
	#instVars : [
		'collection'
	],
	#category : 'GToolkit4Git-Model'
}

{ #category : 'api - instance creation' }
GtGitRepositories class >> default [
	^ self new collection: self defaultCollection
]

{ #category : 'defaults' }
GtGitRepositories class >> defaultCollection [
	^ Array 
			new: IceRepository registry size 
			streamContents: [ :aStream | 
				IceRepository registry do: [ :eachRepository |
					aStream nextPut: (GtGitRepository new repository: eachRepository) ] ]
]

{ #category : 'api - accessing' }
GtGitRepositories >> collection [
	^ collection
]

{ #category : 'api - accessing' }
GtGitRepositories >> collection: aCollection [
	collection := aCollection
]

{ #category : 'gt - extensions' }
GtGitRepositories >> gtRepositoriesFor: aView [
	<gtView>
	self collection ifNil: [ ^ aView empty ].
	^ aView list
		title: 'Repositories';
		items: [ self collection ];
		itemText: #name
]

{ #category : 'initialization' }
GtGitRepositories >> initialize [
	super initialize.
	collection := Array empty.
]

{ #category : 'api - accessing' }
GtGitRepositories >> repositoriesCount [
	^ self collection size
]
