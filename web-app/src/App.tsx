import React from 'react';
import logo from './logo.svg';
import './App.css';
import pB from "./components/PipelineBox"
import PipelineBox from './components/PipelineBox';
import type { PipelineBoxProps, ServiceProps } from './components/PipelineBox';
import PipelineCreation from './components/PipelineCreation';
import PipelineBoxesLayout from './components/PipelineBoxesLayout';

function App() {
 
  let svc: ServiceProps = {
    altText: "youTube", imageSrc: "https://upload.wikimedia.org/wikipedia/commons/0/09/YouTube_full-color_icon_%282017%29.svg" 
  }
  let svc2: ServiceProps = {
    altText: "Spotify", imageSrc: "https://upload.wikimedia.org/wikipedia/commons/8/84/Spotify_icon.svg" 
  }

  let data:Array<PipelineBoxProps> = [
    {
      title: 'My super action',
      statusText: "Last: 2d ago", 
      service1: svc ,
      service2: svc2
    },
    {
      title: 'Lorem ipsum behm uit\'s long',
      statusText: "Lego Star Wars: The Skywalker Saga is an upcoming Lego-themed action-adventure game developed by Traveller's Tales and published by Warner Bros. Interactive Entertainment. It will be the sixth entry in TT Games' Lego Star Wars series of video games and the successor to Lego Star Wars: The Force", 
      service1: svc2 ,
      service2: svc
    },
    {
      title: 'My super action',
      statusText: "Last: 2d ago", 
      service1: svc ,
      service2: svc2
    },
    {
      title: 'Lorem ipsum behm uit\'s long',
      statusText: "Vive la france !", 
      service1: svc2 ,
      service2: svc
    },
    {
      title: 'My super action',
      statusText: "Last: 2d ago", 
      service1: svc ,
      service2: svc2
    },
    {
      title: 'Lorem ipsum behm uit\'s long',
      statusText: "Vive la france !", 
      service1: svc2 ,
      service2: svc
    },
    {
      title: 'My super action',
      statusText: "Last: 2d ago", 
      service1: svc ,
      service2: svc2
    },
    {
      title: 'Lorem ipsum behm uit\'s long',
      statusText: "Vive la france !", 
      service1: svc2 ,
      service2: svc
    },
    {
      title: 'My super action',
      statusText: "Last: 2d ago", 
      service1: svc ,
      service2: svc2
    },
  ]

  return (
    <div className="App">
      <header className="App-header">
        <div id='container'>
          <PipelineBoxesLayout data={data} />
        </div>
      </header>
    </div>
  );
}

export default App;
