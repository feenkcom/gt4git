Class {
	#name : 'GtGitRepositoriesViewModel',
	#superclass : 'Object',
	#traits : 'TGtGitWithRepositoriesModel',
	#classTraits : 'TGtGitWithRepositoriesModel classTrait',
	#instVars : [
		'repositoryViewModels'
	],
	#category : 'GToolkit4Git-UI - View Model'
}

{ #category : 'api - actions' }
GtGitRepositoriesViewModel >> fetchAllSource: aSource [
	
	self flag: 'todo'
]

{ #category : 'initialization' }
GtGitRepositoriesViewModel >> initialize [
	super initialize.
	repositoryViewModels := Array empty.
]

{ #category : 'api - repositories model' }
GtGitRepositoriesViewModel >> onRepositoriesModelChanged [
	"Is sent when a new repositories model is assigned to the view model"
	
	repositoryViewModels := Array
		new: self repositoriesModel repositoriesCount
		streamContents: [ :aStream |
			self repositoriesModel collection do: [ :eachRepository | 
				| aViewModel |
				aViewModel := GtGitRepositoryViewModel new repositoryModel: eachRepository.
				aStream nextPut: aViewModel ] ]
]

{ #category : 'api - repositories' }
GtGitRepositoriesViewModel >> repositories [
	^ repositoryViewModels
]
