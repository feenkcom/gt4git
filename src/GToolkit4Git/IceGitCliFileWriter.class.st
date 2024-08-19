Class {
	#name : #IceGitCliFileWriter,
	#superclass : #IceMetadatalessFileTreeWriter,
	#traits : 'TIceRepositoryWriter',
	#classTraits : 'TIceRepositoryWriter classTrait',
	#category : #'GToolkit4Git-Writer'
}

{ #category : #accessing }
IceGitCliFileWriter class >> description [

	^ 'Tonel'
]

{ #category : #accessing }
IceGitCliFileWriter class >> directoryNameFor: aPackage [
	^ aPackage name, '.package'
]

{ #category : #accessing }
IceGitCliFileWriter class >> id [
	^ #filetreecli
]
